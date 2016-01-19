# coding: utf-8

set :plants, Implementation[:plants]

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
			id = settings.plants.create(JSON.parse(request.body.read))
			
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end
end