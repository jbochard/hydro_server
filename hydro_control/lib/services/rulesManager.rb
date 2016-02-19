require 'mongo'
require 'json'
require 'services/exceptions'

class RulesManager

	def initialize(sensorService)
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
        @sensorService = sensorService
        @rules = {}
        get_all.each do |rule|
        	@rules[rule["_id"]] = Rule.new(rule["name"], rule["condition"], rule["action"], rule["active"], sensorService)
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
		rule = Rule.new(name, condition, action, active, @sensorService)
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
		@rules[rule_id] = Rule.new(rule["name"], rule["condition"], rule["action"], rule["active"], @sensorService)
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
end

class Rule
	attr_reader :name, :condition, :action
	attr_accessor :active

	def initialize(name, condition, action, active, sensorService)
		@name = name
		@sensorService = sensorService
		@condition = condition
		@context = {}
		@action = action
		@active = active
	end
 
	def evaluate
		puts "Evaluando regla #{@name}"
		@context = @sensorService.get_context
		b = binding		
		b.eval(@action) if b.eval(@condition)
	end

	def switch(name, value)
		@sensorService.switch(@context[name][:_id], value)
	end
end
