# coding: utf-8

set :sensorService,		 	Implementation[:sensors]
set :sensor_post_schema, 	JSON.parse(File.read("#{$libdir}/schemas/sensor_post.schema"))

namespace '/hydro_client' do
 
	get '/:command' do |command|
		content_type :json
		status 200
		settings.sensorService.read(command).to_json
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.sensor_post_schema, body)

			if body["type"] == "switch"
				status 200
				settings.sensorService.switch(body["relay"], body["state"]).to_json
			end			
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json
		end
	end
end