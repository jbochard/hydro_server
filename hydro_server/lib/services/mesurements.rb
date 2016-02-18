require 'mongo'
require 'services/exceptions'

class Mesurements

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
		if @mongo_client[:mesurements].find.to_a.length == 0
			@mongo_client[:mesurements].insert_many([ 
				{ :_id => BSON::ObjectId.new.to_s, :order => 0, :type => "ELECTRICAL_CONDUC_HAND", :name => "Conductividad eléctrica"}, 
				{ :_id => BSON::ObjectId.new.to_s, :order => 1, :type => "PH", :name => "PH"}, 
				{ :_id => BSON::ObjectId.new.to_s, :order => 2, :type => "HUMIDITY", :name => "Humedad ambiente"},
				{ :_id => BSON::ObjectId.new.to_s, :order => 3, :type => "TEMP_ENV", :name => "Temperatura ambiente"}, 
				{ :_id => BSON::ObjectId.new.to_s, :order => 4, :type => "PHOTO", :name => "Luz"}, 
				{ :_id => BSON::ObjectId.new.to_s, :order => 5, :type => "TEMP_FLUID", :name => "Temperatura del fluído"},
				{ :_id => BSON::ObjectId.new.to_s, :order => 6, :type => "SOIL_MOISTURE_1", :name => "Conductividad 1"},
				{ :_id => BSON::ObjectId.new.to_s, :order => 7, :type => "SOIL_MOISTURE_2", :name => "Conductividad 2"},
				{ :_id => BSON::ObjectId.new.to_s, :order => 8, :type => "SOIL_MOISTURE_3", :name => "Conductividad 3"}
			])
		end
	end

	def create(mesurement)
		mesurement[:_id] = BSON::ObjectId.new.to_s
		@mongo_client[:mesurements].insert_one(mesurement)
		mesurement[:_id]
	end

	def get_all
		@mongo_client[:mesurements].find({}, :sort => [ "order", 1 ] ).to_a
	end

	def exists?(type)
		@mongo_client[:mesurements].find({ :type => type }).to_a.length > 0
	end
end