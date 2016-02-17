# coding: utf-8

set :hydroponicSerivces, Implementation[:hydroponic]
set :nursery_post_schema, 							JSON.parse(File.read("lib/schemas/nursery_post.schema"))
set :nursery_patch_register_mesurement_schema, 		JSON.parse(File.read("lib/schemas/nursery_patch_register_mesurement.schema"))
set :nursery_patch_change_water_schema, 			JSON.parse(File.read("lib/schemas/nursery_patch_change_water.schema"))
set :nursery_patch_fumigation_schema, 				JSON.parse(File.read("lib/schemas/nursery_patch_fumigation.schema"))

namespace '/nurseries' do
 
	get '/?' do
		content_type :json
		status 200
		settings.hydroponicSerivces.get_all_nurseries.to_json
	end

	get '/:nursery_id' do |nursery_id|
		content_type :json
		begin
			status 200
			settings.hydroponicSerivces.get_nursery(nursery_id).to_json
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

	put '/:nursery_id' do |nursery_id|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.nursery_post_schema, body)
			id = settings.hydroponicSerivces.update_nursery(nursery_id, body)
			
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
		    when "REGISTER_MESUREMENT"
				JSON::Validator.validate!(settings.nursery_patch_register_mesurement_schema, body)
				id = settings.hydroponicSerivces.register_mesurement(nursery_id, body["value"])
		    when "CHANGE_WATER"
				JSON::Validator.validate!(settings.nursery_patch_change_water_schema, body)
				id = settings.hydroponicSerivces.change_water_nursery(nursery_id)
		    when "FUMIGATION"
				JSON::Validator.validate!(settings.plant_patch_fumigation_schema, body)
				id = settings.hydroponicSerivces.fumigation_nursery(nursery_id, body["value"])	

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