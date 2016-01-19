require 'mongo'
require 'services/exceptions'

class Plants

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def exists?(id)
       	plant_id = BSON::ObjectId(id)
		@mongo_client[:plants].find({ :_id => plant_id }).to_a.length > 0
	end

	def get_all
        @mongo_client[:plants].find.projection({ _id: 1, type: 1, creation_date: 1 }).to_a
	end

	def get(id)
		if ! exists?(id)
			raise NotFoundException.new :plant, id
		end
       	plant_id = BSON::ObjectId(id)
        @mongo_client[:plants].find({:_id => plant_id }).to_a.first
	end

	def create(plant)
		plant["_id"] = BSON::ObjectId.new
		plant["creation_date"] = Date.new
		plant["mesurements"] = []
		@mongo_client[:plants].insert_one(plant)
		plant["_id"]
	end

	def add_measurement(buckets, mesurement)
		result = []
		buckets.each do |bucket|
			id = bucket["plant_id"]
			plant = get(id.to_s)
			plant["mesurements"].push(mesurement)
	        @mongo_client[:plants].replace_one(plant)
	        result << plant["_id"]
		end
		result
	end
end