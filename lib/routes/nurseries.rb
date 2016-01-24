# coding: utf-8

set :hydroponicSerivces, Implementation[:hydroponic]
set :nursery_post_schema, 							JSON.parse(File.read("lib/schemas/nursery_post.schema"))
set :nursery_patch_set_plant_in_bucket_schema, 		JSON.parse(File.read("lib/schemas/nursery_patch_set_plant_in_bucket.schema"))
set :nursery_patch_register_mesurement_schema, 		JSON.parse(File.read("lib/schemas/nursery_patch_register_mesurement.schema"))

namespace '/nurseries' do
 
	get '/?' do
		content_type :json
		status 200
		settings.hydroponicSerivces.get_all_nurseries.to_json
	end

	get '/:id' do |id|
		content_type :json
		begin
			status 200
			settings.hydroponicSerivces.get_nursery(id).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.nursery_post_schema, body)
			id = settings.hydroponicSerivces.create_nursery(body)
			
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

	patch '/:nursery_id' do |nursery_id|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			case body["op"].upcase			
			when "SET_PLANT_IN_BUCKET"
				JSON::Validator.validate!(settings.nursery_patch_set_plant_in_bucket_schema, body)
				id = settings.hydroponicSerivces.set_plant_in_bucket(body["value"]["plant_id"], nursery_id, body["value"]["position"])

		    when "REMOVE_PLANT_FROM_BUCKET"
				JSON::Validator.validate!(settings.nursery_patch_remove_plant_from_bucket_schema, body)
				id = settings.hydroponicSerivces.remove_plant_from_bucket(body["value"]["plant_id"])

		    when "REGISTER_MESUREMENT"
				JSON::Validator.validate!(settings.nursery_patch_register_mesurement_schema, body)
				id = settings.hydroponicSerivces.register_mesurement(nursery_id, body["value"])
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

	delete '/:nursery_id' do |nursery_id|
		content_type :json
		begin
			id = settings.hydroponicSerivces.delete_nursery(nursery_id).to_json

			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end		
	end
end