# coding: utf-8

set :rulesManager, 							Implementation[:rules]

namespace '/hydro_control/rules' do
 
	get '/?' do
		content_type :json
		status 200
		settings.rulesManager.get_all.to_json
	end

	get '/:rule_id' do |rule_id|
		content_type :json
		begin
			status 200
			settings.rulesManager.get(rule_id).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			# JSON::Validator.validate!(settings.sensor_post_schema, body)

			id = settings.rulesManager.create(body["name"], body["description"], body["condition"], body["action"], body["else_action"], body["enable"])
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

	post '/test/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			result = settings.rulesManager.test(body["condition"], body["action"], body["else_action"])
			status 200
			result.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json

		end
	end

	put '/:rule_id' do |rule_id| 
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			# JSON::Validator.validate!(settings.sensor_post_schema, body)

			id = settings.rulesManager.update(rule_id, body)
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

	patch '/:rule_id' do |rule_id|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			case body["op"].upcase		
			when "ENABLE_RULE"
				# JSON::Validator.validate!(settings.sensor_patch_join_nursery_schema, body)
				res = settings.rulesManager.enableRule(rule_id, body["enable"])				
			end			
			status 200
			{ :enable => res }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json			
		end
	end

	delete '/:rule_id' do |rule_id|
		content_type :json
		begin
			id = settings.rulesManager.delete(rule_id)
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