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

	def test(condition, action, else_action = "")
		context = get_context
		begin
			rule = Rule.new("test", "test", condition, action, else_action, true, RuleManagerMock.new)
        	status = rule.evaluate(context)
	        { :status => status, :context => context, :result => [ status ]}
		rescue Exception => e 
			puts e.message
			puts e.backtrace
	        { :status => status, :context => context, :result => ([ e.message ] + e.backtrace) }
		end		
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
		@sensorService.switch(sensor_id, value, "rule")
	end

	def evaluateRule(rule_id)
		begin
			context = get_context
			result = @rules[rule_id].evaluate(context)
			registerEvaluationOk(rule_id, context, result)
		rescue Exception => e 
			puts e.message
			puts e.backtrace
			registerEvaluationError(rule_id, context, e)
		end
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

	def initialize(id, name, condition, action, else_action, enable, ruleManager)
		@id = id
		@name = name
		@enable = enable
		@condition = condition
		@action = action
		@else_action = else_action
		@context = {}
		@ruleManager = ruleManager
	end
 
	def evaluate(context)
		if @enable
			@context = context
			puts "Evaluando regla #{@name}"
			puts "Condición: #{@condition}" if Environment.debug
			puts "Acción: #{@action}" 		if Environment.debug
			puts "Else: #{@else_action}" 	if Environment.debug
			b = binding		
			eval_condition = b.eval(@condition)
			if eval_condition
				b.eval(@action) 
				return 'OK'
			end
			if ! @else_action.nil? && @else_action.length > 0 && ! eval_condition
				b.eval(@else_action) 
				return 'OK_ELSE'
			end
			return 'NO'
		end
	end

	def enableState(enable)
		@enable = enable
	end

	def param(name)
		s = @context.select {|s| s[:category] == 'PARAM' && s[:name] == name}.first
		if s.nil?
			raise RuleExecutionException.new "Parámetro #{name} no encontrado."
		else
			s[:value]
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
		puts "Ejecutando switch (#{client}, #{name}, #{value}) " if Environment.debug
		s = @context.select {|s| s[:category] == 'INPUT' && s[:client] == client && s[:name] == name}.first
		puts "Switch: #{s}" if Environment.debug
		if s.nil?
			raise RuleExecutionException.new "Switch #{client}_#{name} no encontrado."
		else
			puts "Ejecutando switch en: #{@ruleManager.class}"
			@ruleManager.switch(s[:_id], value)
		end
	end
end

class RuleManagerMock
	def switch(sensor_id, value)
		puts "Exec. switch(#{sensor_id}, #{value})"
	end
end