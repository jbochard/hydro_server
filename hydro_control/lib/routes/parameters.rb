set :parameters, 							Implementation[:parameters]

namespace '/hydro_control/parameters' do
 
	get '/?' do
		content_type :json
		status 200
		settings.parameters.get_all.to_json
	end

	get '/:param_id' do |param_id|
		content_type :json
		begin
			status 200
			settings.parameters.get(param_id).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)

			id = settings.parameters.create(body["name"], body["value"])
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

	put '/:param_id' do |param_id| 
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			# JSON::Validator.validate!(settings.sensor_post_schema, body)

			id = settings.parameters.update(param_id, body)
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

	delete '/:param_id' do |param_id|
		content_type :json
		begin
			id = settings.parameters.delete(param_id)
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