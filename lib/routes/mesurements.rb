# coding: utf-8

set :mesurements, Implementation[:mesurements]
set :post_schema, 					JSON.parse(File.read("lib/schemas/mesurements_post.schema"))
#set :patch_add_mesurement_schema, 	JSON.parse(File.read("lib/schemas/plants_patch_add_mesurement.schema"))

namespace '/mesurements' do
 
	get '/?' do
		content_type :json
		status 200
		settings.mesurements.get_all.to_json
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