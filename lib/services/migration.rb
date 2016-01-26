require 'mongo'
require 'services/exceptions'

class Migration

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def migrate
		migrate_plants
		migrate_nurseries
		migrate_plant_types		
	end

	def migrate_plants
		puts "Migrando plants"
		@mongo_client[:plants].find.to_a.each do |plant|
			if ! plant["_id"].is_a? String
				plant["_id"] = plant["_id"].to_s
				plant["type_id"] = plant["type_id"].to_s
				@mongo_client[:plants].insert_one(plant)

				@mongo_client[:plants].find({ :_id => BSON::ObjectId(plant["_id"]) }).delete_one
			end
		end
	end 

	def migrate_nurseries
		puts "Migrando nurseries"
		@mongo_client[:nurseries].find.to_a.each do |nursery|
			if ! nursery["_id"].is_a? String
				nursery["_id"] = nursery["_id"].to_s
				nursery["buckets"].each do |bucket|
					bucket["plant_id"] = bucket["plant_id"].to_s
				end
				@mongo_client[:nurseries].insert_one(nursery)

				@mongo_client[:nurseries].find({ :_id => BSON::ObjectId(nursery["_id"]) }).delete_one
			end
		end
	end

	def migrate_plant_types
		puts "Migrando plant_types"
		@mongo_client[:plant_types].find.to_a.each do |plant_type|
			if ! plant_type["_id"].is_a? String
				plant_type["_id"] = plant_type["_id"].to_s
				@mongo_client[:plant_types].insert_one(plant_type)

				@mongo_client[:plant_types].find({ :_id => BSON::ObjectId(plant_type["_id"]) }).delete_one
			end
		end
	end
end