require 'mongo'
require 'json'
require 'thread'
require 'services/exceptions'
require 'time'

class RulesManager

	def initialize(sensorService, paramService)
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
        @sensorService = sensorService
        @paramService = paramService
        @rules = {}
        get_all.each do |rule|
        	@rules[rule["_id"]] = Rule.new(rule["_id"], rule["name"], rule["condition"], rule["action"], rule["else_action"], rule["enable"], self)
        end
	end

	def exists?(rule_id)
        @mongo_client[:rules].find({ :_id => rule_id }).to_a.length > 0
	end

	def get_all
		@mongo_client[:rules].find.to_a
	end

	def get(rule_id)
		if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
		end		
		@mongo_client[:rules].find({ :_id => rule_id }).to_a.first
	end

	def create(name, description, condition, action, else_action = "", enable = false)
		id = BSON::ObjectId.new.to_s
		rule = Rule.new(id, name, condition, action, else_action, enable, self)
		@rules[id] = rule
		@mongo_client[:rules].insert_one({ :_id => id, :name => name, :description => description, :enable => enable, :condition => condition, :action => action, :else_action => else_action, :status => { :status => 'NO', :last_evaluation => nil } })
		id
	end

	def update(rule_id, rule)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end
 		@mongo_client[:rules]
			.find({ :_id => rule_id })
			.update_one({ '$set' => rule })
		@rules[rule_id] = Rule.new(rule_id, rule["name"], rule["condition"], rule["action"], rule["else_action"], rule["enable"], self)
		rule_id
	end

	def enableRule(rule_id, enable)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end		
        @rules[rule_id].enableState(enable)

    	@mongo_client[:rules]
            .find({ :_id => rule_id })
            .update_one({ '$set' => { :enable => enable } })
        rule_id
	end

	def delete(rule_id)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end
        @rules[rule_id].enableState(false)
    	@rules.delete(rule_id)

		@mongo_client[:rules]
			.find({ :_id => rule_id })
			.delete_one
		rule_id
	end

 	# ---------------------- Métodos de evaluación de reglas ---------------------

	def get_context
		context = @sensorService.get_context
		context = context + [{ :category => 'PARAM', :name => 'now', :value => Time.new.getlocal }]
		context = context + @paramService.get_context
		context
	end

	def switch(sensor_id, value)
		@sensorService.switch(sensor_id, value, :rule)
	end

	def evaluateRule(rule_id)
		@rules[rule_id].evaluate
	end

	def registerEvaluationOk(rule_id, context, st)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end		
    	@mongo_client[:rules]
            .find({ :_id => rule_id })
            .update_one({ '$set' => { :status => { :last_evaluation => Time.new.getlocal, :context => context, :status => st } } })
        rule_id
   	end	

	def registerEvaluationError(rule_id, context, e)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end
    	backtrace = [ e.message ] + e.backtrace
    	@mongo_client[:rules]
            .find({ :_id => rule_id })
            .update_one({ '$set' => { :status => { :last_evaluation => Time.new.getlocal, :context => context, :status => 'ERROR', :backtrace => backtrace } } })
        rule_id
   	end	
end

class Rule
	attr_reader :name, :condition, :action
	attr_accessor :enable

	def initialize(id, name, condition, action, else_action, enable, rulesManager)
		@id = id
		@name = name
		@enable = enable
		@condition = condition
		@action = action
		@else_action = else_action
		@context = {}
        @semaphore = Mutex.new

		@rulesManager = rulesManager
	end
 
	def evaluate
		@semaphore.synchronize {
			if @enable
				begin
					puts "Evaluando regla #{@name}"
					@context = @rulesManager.get_context
					b = binding		
					eval_condition = b.eval(@condition)
					if eval_condition
						b.eval(@action) 
						@rulesManager.registerEvaluationOk(@id, @context, 'OK')
					end
					if ! @else_action.nil? && @else_action.length > 0 && ! eval_condition
						b.eval(@else_action) 
						@rulesManager.registerEvaluationOk(@id, @context, 'OK_ELSE')						
					end
				rescue Exception => e 
					puts e.message
					puts e.backtrace
					@rulesManager.registerEvaluationError(@id, @context, e)
				end
			end
		}
	end

	def enableState(enable)
		@semaphore.synchronize {
			@enable = enable
		}
	end

	def param(name)
		s = @context.select {|s| s[:category] == 'PARAM' && s[:name] == name}.first
		if s.nil?
			raise RuleExecutionException.new "Parámetro #{name} no encontrado."
		else
			s['value']
		end
	end

	def sensor(client, name)
		s = @context.select {|s| s[:category] == 'OUTPUT' && s[:client] == client && s[:name] == name}.first
		if s.nil?
			raise RuleExecutionException.new "Sensor #{client} - #{name} no encontrado."
		else			
			s['value'].to_f
		end
	end

	def switch(client, name, value)
		s = @context.select {|s| s[:category] == 'INPUT' && s[:client] == client && s[:name] == name}.first
		if s.nil?
			raise RuleExecutionException.new "Switch #{client}_#{name} no encontrado."
		else
			@rulesManager.switch(s[:_id], value) if ! s.nil?
		end
	end
end
