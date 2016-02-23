
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

	def get_all(query = {})
    	@mongo_client[:sensors].find(query).projection({ _id: 1, type: 1, category: 1, client:1, name: 1, enable: 1,  value: 1 }).to_a
	end

	def get_context
    	context = Hash[@mongo_client[:sensors].find({ :enable => true }).projection({ _id: 1, type: 1, category: 1, client:1, name: 1, enable: 1,  value: 1 })
    		.to_a
    		.group_by { |s| s[:client] } 
    	]
    	context
	end

	def get(sensor_id)
		if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
		end
        @mongo_client[:sensors].find({ :_id => sensor_id }).to_a.first
  	end

  	def read(sensor_id)
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
		execute_switch(switch["url"], switch['name'], value)
        switch_id
  	end

	def create(client_url)
		if exists_by_url?(client_url)
			raise AlreadyExistException.new :sensor, client_url
		end
		sensors = get_measures(client_url).map { |measure| { :_id => BSON::ObjectId.new.to_s, :url => client_url, :category => 'OUTPUT', :name => measure['sensor'], :client => measure['name'], :type => measure['type'], :enable => false } }
		@mongo_client[:sensors].insert_many(sensors)

		switches = get_switches(client_url).map { |switch| { :_id => BSON::ObjectId.new.to_s, :url => client_url, :category => 'INPUT', :name => switch['switch'], :client => switch['name'], :type => switch['type'], :enable => false } }
		@mongo_client[:sensors].insert_many(switches)	
		client_url
	end

	def update(sensor_id, sensor)
       	if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
    	end
		@mongo_client[:sensors]
			.find({ :_id => sensor_id })
			.update_one({ '$set' => sensor })		
	end

	def enableSensor(sensor_id, value)
      	if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
    	end
		@mongo_client[:sensors]
			.find({ :_id => sensor_id })
			.update_one({ '$set' => { :enable => value } })
		value
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

	def execute_switch(client_url, switch, value)
		begin
			body = { :type => 'SWITCH', :relay => switch, :state => value }.to_json
			url = URI.parse("#{client_url}")
			req = Net::HTTP::Post.new(url.to_s, initheader = { 'Content-Type' => 'application/json'})
			req.body = "#{body}"
			res = Net::HTTP.start(url.host, url.port) { |http|
				http.request(req)
			}
			result  = JSON.parse(res.body)
			return result["state"]
		rescue Exception => e
			puts "Error: #{e}"
		end		
	end
end