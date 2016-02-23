require 'mongo'
require 'json'
require 'services/exceptions'

class RulesManager

	def initialize(sensorService, paramService)
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
        @sensorService = sensorService
        @paramService = paramService
        @rules = {}
        get_all.each do |rule|
        	@rules[rule["_id"]] = Rule.new(rule["name"], rule["condition"], rule["action"], rule["active"], self)
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

	def create(name, condition, action, active = false)
		id = BSON::ObjectId.new.to_s
		rule = Rule.new(name, condition, action, active, self)
		@rules[id] = rule
		@mongo_client[:rules].insert_one({ :_id => id, :name => name, :active => active, :condtion => condition, :action => action })
		id
	end

	def update(rule_id, rule)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end
		@mongo_client[:rules]
			.find({ :_id => rule_id })
			.update_one({ '$set' => rule })
		@rules[rule_id] = Rule.new(rule["name"], rule["condition"], rule["action"], rule["active"], self)
		rule_id
	end

	def enableRule(rule_id, active)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end		
    	@mongo_client[:rules]
            .find({ :_id => rule_id })
            .update_one({ '$set' => { :active => active } })
            @rules[rule_id].active = active
        rule_id
	end

	def registerEvaluation(rule_id)
       	if ! exists?(rule_id)
			raise NotFoundException.new :rules, rule_id
    	end		
    	@mongo_client[:rules]
            .find({ :_id => rule_id })
            .update_one({ '$set' => { :last_evaluation => Time.new } })
        rule_id
   	end

	def evaluate_active
		@rules.each do |k, r|
			if r.active
				r.evaluate
				registerEvaluation(k)
			end
		end
	end

	def get_context
		context = @sensorService.get_context
		context["now"] = Time.new
		context.merge!(@paramService.get_context)
		context
	end

	def switch(sensor_id, value)
		@sensorService.switch(sensor_id, value)
	end
end

class Rule
	attr_reader :name, :condition, :action
	attr_accessor :active

	def initialize(name, condition, action, active, rulesManager)
		@name = name
		@rulesManager = rulesManager
		@condition = condition
		@context = {}
		@action = action
		@active = active
	end
 
	def evaluate
		puts "Evaluando regla #{@name}"
		@context = @rulesManager.get_context
		b = binding		
		b.eval(@action) if b.eval(@condition)
	end

	def switch(client, name, value)
		s = @context[client].select {|s| s[:category] == 'INPUT' && s[:name] == name}.first
		@rulesManager.switch(s[:_id], value) if ! s.nil?
	end
end
