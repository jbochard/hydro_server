require 'mongo'
require 'services/exceptions'

class Mesurements

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def create(mesurement)
		mesurement[:_id] = BSON::ObjectId.new
		@mongo_client[:mesurements].insert_one(mesurement)
		mesurement[:_id]
	end

	def get_all
		@mongo_client[:mesurements].find.to_a
	end
end