
require 'mongo'
require 'net/http'
require 'json'
require 'services/exceptions'

class Sensors

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def exists?(sensor_id)
        @mongo_client[:sensors].find({ :_id => sensor_id }).to_a.length > 0
	end

	def exists_by_url?(client_url)
        @mongo_client[:sensors].find({ :url => client_url }).to_a.length > 0
	end

	def get_all
    	@mongo_client[:sensors].find.projection({ _id: 1, url: 1 }).to_a
	end

	def get_joinded
		result = []
    	@mongo_client[:sensors].find.to_a.each do |sensor|
    		result << {
    			:url => sensor["url"]
    			:measures => sensor["measures"]
    		}
    	end
	end

	def get(sensor_id)
		if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
		end
        @mongo_client[:sensors].find({ :_id => sensor_id }).to_a.first
  	end

	def create(client_url)
		if exists_by_url?(client_url)
			raise AlreadyExistException.new :sensor, client_url
		end

		sensor = { :_id => BSON::ObjectId.new.to_s, :url => client_url }
		sensor["measures"] = get_measures(client_url).map { |measure| { :measure => measure, :join => [] }}
		
		@mongo_client[:sensors].insert_one(sensor)
		sensor[:_id]
	end

	def join_nursery(sensor_id, value)
		@mongo_client[:sensors]
            .find({ :_id => sensor_id, "measures.measure" => value["measure"] })
            .update_many({ '$push' => { "measures.$.join" => {  :type => :nursery, :_id => value["nursery_id"] } } })
        sensor_id
	end

	def join_plant(sensor_id, value)
		@mongo_client[:sensors]
            .find({ :_id => sensor_id, "measures.measure" => value["measure"] })
            .update_many({ '$push' => { "measures.$.join" => {  :type => :plant, :_id => value["plant_id"] } } })
        sensor_id
	end

	def update(sensor_id, sensor)
       	if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
    	end
		@mongo_client[:sensors]
		.find({ :_id => sensor_id })
		.update_one({ '$set' => sensor })		
	end

	def get_measures(client_url)
		url = URI.parse("#{client_url}/measures")
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}
		JSON.parse(res.body)
	end

	def read_measure(client_url, measure)
		url = URI.parse("#{client_url}/#{measure}")
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}
		JSON.parse(res.body)
	end
end