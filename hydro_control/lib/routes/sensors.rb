# coding: utf-8

set :sensorSerivces, 						Implementation[:sensors]
set :sensor_post_schema, 					JSON.parse(File.read("lib/schemas/sensor_post.schema"))

namespace '/sensors' do
 
	get '/?' do
		content_type :json
		status 200
		settings.sensorSerivces.get_all(params[:query]).to_json
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
end