# coding: utf-8

set :nurseries, Implementation[:nurseries]

namespace '/nurseries' do
 
	get '/?' do
		content_type :json
		status 200
		settings.nurseries.get_all.to_json
	end

	get '/:name' do |name|
		content_type :json
		begin
			status 200
			settings.nurseries.get(name).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			id = settings.nurseries.create(JSON.parse(request.body.read))
			
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	patch '/:name' do |name|
		content_type :json
		begin
			id = settings.nurseries.update(name, JSON.parse(request.body.read))
			
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	delete '/:name' do |name|
		content_type :json
		begin
			id = settings.nurseries.delete(name).to_json

			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end		
	end
end