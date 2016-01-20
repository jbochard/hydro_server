# coding: utf-8

set :plants, Implementation[:plants]
set :post_schema, 					JSON.parse(File.read("lib/schemas/plants_post.schema"))
set :patch_add_mesurement_schema, 	JSON.parse(File.read("lib/schemas/plants_patch_add_mesurement.schema"))

namespace '/plants' do
 
	get '/?' do
		content_type :json
		status 200
		settings.plants.get_all.to_json
	end

	get '/:id' do |id|
		content_type :json
		begin
			status 200
			settings.plants.get(id).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.post_schema, body)

			id = settings.plants.create(JSON.parse(request.body.read))
			
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

	patch '/:id' do |id|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			case body["op"].upcase
			when "ADD_MESUREMENT"
				JSON::Validator.validate!(settings.patch_add_mesurement_schema, body)
				id = settings.plants.add_mesurement(id, body["value"])
			end
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