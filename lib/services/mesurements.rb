require 'mongo'
require 'services/exceptions'

class Mesurements

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
		if @mongo_client[:mesurements].find.to_a.length == 0
			@mongo_client[:mesurements].insert_many([ 
				{ :type => "environment temperature", :name => "Temperatura ambiente"}, 
				{ :type => "PH", :name => "PH"}, 
				{ :type => "electrical conductivity ", :name => "Conductividad eléctrica"}, 
				{ :type => "flow temperature", :name => "Temperatura del fluído"}, 
				{ :type => "air humidity", :name => "Humedad ambiente"} 
				])
		end
	end

	def create(mesurement)
		mesurement[:_id] = BSON::ObjectId.new
		@mongo_client[:mesurements].insert_one(mesurement)
		mesurement[:_id]
	end

	def get_all
		@mongo_client[:mesurements].find.to_a
	end

	def exists?(type)
		@mongo_client[:mesurements].find({ :type => type }).to_a.length > 0
	end
end