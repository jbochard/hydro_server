require 'mongo'
require 'json'
require 'services/exceptions'

class Parameters

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def exists?(param_id)
        @mongo_client[:parameters].find({ :_id => param_id }).to_a.length > 0
	end

	def get_all
		@mongo_client[:parameters].find.to_a
	end

	def get_context
    	context = Hash[
    		@mongo_client[:parameters]
    			.find
    			.map { |param| [ param["name"], param["value"] ] }
    	]
    	context
	end

	def get(param_id)
		if ! exists?(param_id)
			raise NotFoundException.new :parameters, param_id
		end		
		@mongo_client[:parameters].find({ :_id => param_id }).to_a.first
	end

	def create(name, value)
		id = BSON::ObjectId.new.to_s
		@mongo_client[:parameters].insert_one({ :_id => id, :name => name, :value => value })
		id
	end

	def update(param_id, param)
       	if ! exists?(param_id)
			raise NotFoundException.new :parameters, param_id
    	end
		@mongo_client[:parameters]
		.find({ :_id => param_id })
		.update_one({ '$set' => param })
		param_id
	end

	def delete(param_id)
       	if ! exists?(param_id)
			raise NotFoundException.new :parameters, param_id
    	end
		@mongo_client[:parameters]
			.find({ :_id => param_id })
			.delete_one
		param_id
	end
end
