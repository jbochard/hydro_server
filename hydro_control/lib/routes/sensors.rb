# coding: utf-8

set :sensorSerivces, 						Implementation[:sensors]
set :sensor_post_schema, 					JSON.parse(File.read("#{$libdir}/schemas/sensor_post.schema"))

namespace '/hydro_control/sensors' do
 
	get '/?' do
		content_type :json
		status 200

		if ! params[:byClient].nil?
			return settings.sensorSerivces.get_all_by_client(params[:query]).to_json			
		end
		return settings.sensorSerivces.get_all(params[:query]).to_json
	end

	get '/:sensor_id' do |sensor_id|
		content_type :json
		begin
			status 200
			settings.sensorSerivces.get(sensor_id).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.sensor_post_schema, body)

			url = settings.sensorSerivces.create(body["url"])
			status 200
			{ :url => url }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json

		end
	end

	put '/:sensor_id' do |sensor_id| 
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.sensor_post_schema, body)

			id = settings.sensorSerivces.update(sensor_id, body)
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json

		end
	end

	patch '/:sensor_id' do |sensor_id|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			case body["op"].upcase		
			when "ENABLE_SENSOR"
				# JSON::Validator.validate!(settings.sensor_patch_join_nursery_schema, body)
				state = settings.sensorSerivces.enableSensor(sensor_id, body["enable"])				
				status 200
				{ :_id => sensor_id, :state => state }.to_json
			when "CONTROL"
				# JSON::Validator.validate!(settings.sensor_patch_join_nursery_schema, body)
				cont = settings.sensorSerivces.controlSensor(sensor_id, body["type"])				
				status 200
				{ :_id => sensor_id, :control => cont }.to_json
			when "SWITCH"
				# JSON::Validator.validate!(settings.sensor_patch_join_nursery_schema, body)
				state = settings.sensorSerivces.switch(sensor_id, body["value"], "manual")				
				status 200
				{ :_id => sensor_id, :state => state }.to_json
			end			
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json			
		end
	end

	delete '/?' do
		content_type :json
		begin
			# body = JSON.parse(request.body.read)
			url = params[:url][1..-2]
			url = settings.sensorSerivces.delete(url)
			status 200
			{ :url => url }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json

		end
	end
end