# coding: utf-8

set :rulesManager, 							Implementation[:rules]

namespace '/rules' do
 
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

			id = settings.rulesManager.create(body["condition"], body["action"])
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
				settings.rulesManager.enableRule(rule_id, body["active"])				
			end			
			status 200
			{ :_id => rule_id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json			
		end
	end
end