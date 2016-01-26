require 'mongo'
require 'services/exceptions'

class PlantTypes

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
		if @mongo_client[:plant_types].find.to_a.length == 0
			@mongo_client[:plant_types].insert_many([ 
				{ :_id => BSON::ObjectId.new.to_s, :name => "Menta"}, 
				{ :_id => BSON::ObjectId.new.to_s, :name => "Albahaca"}, 
				{ :_id => BSON::ObjectId.new.to_s, :name => "Lechuga manteca"}, 
				{ :_id => BSON::ObjectId.new.to_s, :name => "Rúcula"}, 
				{ :_id => BSON::ObjectId.new.to_s, :name => "Ciboulette"}, 
				{ :_id => BSON::ObjectId.new.to_s, :name => "Desconocido"} 
				])
		end
	end

	def create(plant_type)
		plant_type[:_id] = BSON::ObjectId.new.to_s
		@mongo_client[:plant_types].insert_one(plant_type)
		plant_type[:_id]
	end

	def get_all
		@mongo_client[:plant_types].find.to_a
	end

	def get(id)
		@mongo_client[:plant_types].find( { :_id => id }).to_a.first
	end

	def get_by_name(name)
		@mongo_client[:plant_types].find( { :name => name } ).to_a.first
	end

	def exists?(name)
		@mongo_client[:plant_types].find({ :name => name }).to_a.length > 0
	end
end