require 'mongo'
require 'services/exceptions'

class Plants

	def initialize(configurationService, mesurementService, plantTypesService)
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
        @mesurementService = mesurementService
        @configurationService = configurationService
        @plantTypesService = plantTypesService
	end

	def exists?(plant_id)
       	plant_id = BSON::ObjectId(plant_id)
		@mongo_client[:plants].find({ :_id => plant_id }).to_a.length > 0
	end

	def get_all
        @mongo_client[:plants].
        	find.
        	projection({ _id: 1, code: 1, type: 1, type_id: 1, creation_date: 1, bucket: 1 }).
        	to_a.map do |plant|
        		if plant.has_key?("type")
        			plant_type = @plantTypesService.get_by_name(plant["type"])
	        		plant["type_id"] 	= plant_type["_id"]
	       			plant.delete("type")
	       			@mongo_client[:plants].find({ :_id => plant["_id"] }).update_one(plant)

	        		plant["type_name"] 	= plant_type["name"]
	       			plant
	       		else
	       			puts "Plant: #{plant}"
	       			puts "Type ID: #{plant['type_id']}"
	       			puts "ID class: #{plant['type_id'].class.to_s}"
	       			puts "ID: #{plant['type_id'].inspect}"
	       			plant["type_name"] = @plantTypesService.get(plant['type_id'])["name"]
	       			plant
	       		end
        	end
	end

	def get(plant_id)
		if ! exists?(plant_id)
			raise NotFoundException.new :plant, plant_id
		end
        plant = @mongo_client[:plants].find({:_id => BSON::ObjectId(plant_id) }).to_a.first
		plant["type_name"] = @plantTypesService.get(plant["type_id"])["type_name"]
		plant
	end

	def create(plant)
		plant["_id"] = BSON::ObjectId.new
		plant["code"] = @configurationService.get_plant_code
		plant["type_id"] = BSON::ObjectId(plant["type_id"]["$oid"])
		plant["creation_date"] = Time.new
		plant["mesurements"] = []
		plant["bucket"] = {}
		@mongo_client[:plants].insert_one(plant)
		plant["_id"]
	end

	def delete(plant_id)
		if ! exists?(plant_id)
			raise NotFoundException.new :plant, plant_id
		end
        @mongo_client[:plants].find({ :_id => BSON::ObjectId(plant_id) }).delete_one
        plant_id
	end

	def quit_plant_from_bucket(plant_id)
		if ! exists?(plant_id)
			raise NotFoundException.new :plant, plant_id
		end
        @mongo_client[:plants].find({ :_id => BSON::ObjectId(plant_id) }).update_one({ '$set' => { :bucket => {} } })
	end

	def insert_plant_in_bucket(plant_id, nursery_id, nursery_name, nursery_position)
		if ! exists?(plant_id)
			raise NotFoundException.new :plant, plant_id
		end
        @mongo_client[:plants].find({ :_id => BSON::ObjectId(plant_id) }).update_one({ '$set' => { :bucket => { :nursery_id => BSON::ObjectId(nursery_id), :nursery_name => nursery_name, :nursery_position => nursery_position } } })
	end

	def register_mesurement(plant_id, mesurement)
		plant = get(plant_id)

		if ! @mesurementService.exists?(mesurement["type"])
			raise NotFoundException.new :mesurement, mesurement["type"]
		end

         @mongo_client[:plants]
            .find({ :_id => BSON::ObjectId(plant_id) })
            .update_one({ '$push' => { :mesurements => mesurement } })
		plant_id
	end
end