
require 'mongo'
require 'net/http'
require 'json'
require 'services/exceptions'

class Sensors

	def initialize(nurseriesService, plantsService)
		@nurseriesService = nurseriesService
		@plantsService = plantsService
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def exists?(sensor_id)
        @mongo_client[:sensors].find({ :_id => sensor_id }).to_a.length > 0
	end

	def exists_by_url?(client_url)
        @mongo_client[:sensors].find({ :url => client_url }).to_a.length > 0
	end

	def get_all(query = {})
    	@mongo_client[:sensors].find(query).projection({ _id: 1 }).to_a
	end

	def get(sensor_id)
		if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
		end
        @mongo_client[:sensors].find({ :_id => sensor_id }).to_a.first
  	end

  	def read(sensor_id)
  		puts "Read sensor: #{sensor_id}"
  		sensor = get(sensor_id)
		value = read_measure(sensor["url"], sensor["name"])
		if value.nil?
			sensor.delete("date")
			sensor.delete("value")
		else
			sensor["date"] = Time.new
			sensor["value"] = value
  		end
  		update(sensor_id, sensor)
        sensor_id
  	end

  	def switch(switch_id, value)
  		switch = get(switch_id)
  		puts "Switch #{switch['name']}_#{value}"
		switch(sensor["url"], switch['name'], value)
        switch_id
  	end

	def create(client_url)
		if exists_by_url?(client_url)
			raise AlreadyExistException.new :sensor, client_url
		end
		sensors = get_measures(client_url).map { |measure| { :_id => BSON::ObjectId.new.to_s, :url => client_url, :type => 'OUTPUT', :name => measure, :join => [] }}
		@mongo_client[:sensors].insert_many(sensors)

		switches = get_switches(client_url).map { |switch| { :_id => BSON::ObjectId.new.to_s, :url => client_url, :type => 'INPUT', :name => switch }}
		@mongo_client[:sensors].insert_many(switches)	
		client_url
	end

	def join_nursery(sensor_id, value)
        if ! @nurseriesService.exists?(value["nursery_id"])
            raise NotFoundException.new :nursery, value["nursery_id"]
        end		
		@mongo_client[:sensors]
            .find({ :_id => sensor_id, "measures.measure" => value["measure"] })
            .update_many({ '$push' => { "measures.$.join" => {  :type => :nursery, :_id => value["nursery_id"] } } })
        sensor_id
	end

	def join_plant(sensor_id, value)
	    if ! @plantsService.exists?(value["plant_id"])
            raise NotFoundException.new :plant, value["plant_id"]
        end
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


	private
	def get_measures(client_url)
		url = URI.parse("#{client_url}/measures")
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}
		JSON.parse(res.body)
	end

	def get_switches(client_url)
		url = URI.parse("#{client_url}/switches")
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}
		JSON.parse(res.body)
	end

	def read_measure(client_url, measure)
		begin
			puts "GET #{client_url}/#{measure}"
			url = URI.parse("#{client_url}/#{measure}")
			req = Net::HTTP::Get.new(url.to_s)
			res = Net::HTTP.start(url.host, url.port) { |http|
				http.request(req)
			}
			result  = JSON.parse(res.body)
			return result["value"] if result["state"] == 'OK'
		rescue Exception => e
			puts "Error: #{e}"
		end
	end

	def switch(client_url, switch, value)
		
	end
end