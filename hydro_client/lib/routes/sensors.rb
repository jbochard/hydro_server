# coding: utf-8

set :sensor_post_schema, 	JSON.parse(File.read("#{$libdir}/schemas/sensor_post.schema"))

namespace '/hydro_client' do

 	get '/sensors' do
		content_type :json
		status 200
		Sensors.instance.sensors.to_json
	end

	get '/value/:command' do |command|
		content_type :json
    val = Sensors.instance.read(command)
    if val.nil?
      status 404
      { :state => "ERROR", :value => "ERROR" }.to_json
    else
		    status 200
		    val.to_json
    end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.sensor_post_schema, body)

			if body["type"].upcase == "SWITCH"
				status 200
				Sensors.instance.switch(body["relay"], body["state"]).to_json
			end
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json
		end
	end
end
