
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
    	@mongo_client[:sensors].find(query).projection({ _id: 1, type: 1, category: 1, client: 1, name: 1, enable: 1,  value: 1 }).sort({ client: 1, name: 1}).to_a
	end

	def get_all_by_client(query = {})
		query = {} 	if query.nil? || query == ''
		result = {}
    	@mongo_client[:sensors].find(query).projection({ _id: 1, type: 1, url: 1, category: 1, client: 1, name: 1, enable: 1, control: 1, value: 1 }).sort({ client: 1, name: 1}).to_a.each do |sensor|
			result[sensor['client']] = { :name => sensor['client'], :url => sensor['url'], :value => [] } if ! result.has_key?(sensor['client'])
			result[sensor['client']][:value].insert(-1, sensor)
    	end
    	result.values.to_a
	end

	def get_context
    	context = @mongo_client[:sensors].find({ :enable => true }).projection({ _id: 1, type: 1, category: 1, client: 1, name: 1,  value: 1 }).to_a
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
  		res = read_measure(sensor["url"], sensor["name"])
		if res.nil? ||  res["state"] == 'ERROR'
			sensor.delete("date")
			sensor.delete("value")
		else
			sensor["date"] = Time.new
			sensor["value"] = res["value"]
  		end
  		update(sensor_id, sensor)
        sensor_id
  	end

  	def switch(switch_id, value, origin)
  		switch = get(switch_id)
  		if (switch["control"] == "rule" && origin == "rule") || (switch["control"] == "manual" && origin == "manual")
			res = execute_switch(switch["url"], switch['name'], value)
			switch["value"] = res["value"]
			update(switch_id, switch)
		end
        switch["value"]
  	end

	def create(client_url)
		if exists_by_url?(client_url)
			raise AlreadyExistException.new :sensor, client_url
		end
		sensors = get_sensors(client_url).map do |sensor| 
			if sensor["type"] == "SENSOR"
				{ :_id => BSON::ObjectId.new.to_s, :url => client_url, :category => 'OUTPUT', :name => sensor['sensor'], :client => sensor['name'], :type => sensor['type'], :enable => false, :value => 0 }
			else
				{ :_id => BSON::ObjectId.new.to_s, :url => client_url, :category => 'INPUT',  :name => sensor['sensor'], :client => sensor['name'], :type => sensor['type'], :enable => false, :control => 'manual', :value => 'OFF' }
			end
		end
		@mongo_client[:sensors].insert_many(sensors)
		client_url
	end

	def delete(client_url)
       	if ! exists_by_url?(client_url)
			raise NotFoundException.new :sensor, client_url
    	end
   		@mongo_client[:sensors].find({ :url => client_url }).delete_many
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

	def controlSensor(sensor_id, type)
      	if ! exists?(sensor_id)
			raise NotFoundException.new :sensor, sensor_id
    	end
		@mongo_client[:sensors]
			.find({ :_id => sensor_id })
			.update_one({ '$set' => { :control => type } })
		type
	end

	private
	def get_sensors(client_url)
		url = URI.parse("#{client_url}/sensors")
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}
		JSON.parse(res.body)
	end

	def read_measure(client_url, measure)
		begin
			url = URI.parse("#{client_url}/value/#{measure}")
			req = Net::HTTP::Get.new(url.to_s)
			res = Net::HTTP.start(url.host, url.port) { |http|
				http.request(req)
			}
			return JSON.parse(res.body)
		rescue Exception => e
			puts "Error: #{e}"
			puts e.backtrace
		end
	end

	def execute_switch(client_url, switch, value)
		begin
			puts "Ejecutando switch de: #{client_url}, #{switch}, #{value}" if Environment.debug
			body = { :type => 'SWITCH', :relay => switch, :state => value }.to_json
			url = URI.parse("#{client_url}")
			req = Net::HTTP::Post.new(url.to_s, initheader = { 'Content-Type' => 'application/json'})
			req.body = "#{body}"
			res = Net::HTTP.start(url.host, url.port) { |http|
				http.request(req)
			}
			return JSON.parse(res.body)
		rescue Exception => e
			puts "Error: #{e}"
			puts e.backtrace
		end		
	end
end