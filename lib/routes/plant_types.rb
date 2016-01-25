# coding: utf-8

set :plant_types, Implementation[:plant_types]

namespace '/plant_types' do
 
	get '/?' do
		content_type :json
		status 200
		settings.plant_types.get_all.to_json
	end

	get '/:id' do |id|
		content_type :json
		status 200
		settings.plant_types.get(id).to_json
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.post_schema, body)

			id = settings.mesurements.create(body)
			
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