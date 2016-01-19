# coding: utf-8

require 'exceptions'

namespace '/files' do
 
	get '/?' do
		content_type :json
		files = Environment.mocker.get_mocks(params[:query])
		status 200
		files.to_json
	end

	get '/:key' do |key|
		content_type :json
		begin
			status 200
			Environment.mocker.get_mock(key).to_json
		rescue FileNotFoundException => e
			status e.code
			{ :error => "Registro #{e.message} no encontrado. "}.to_json
		end
	end

	get '/config/modules' do
		content_type :json
		status 200
		[ { :value => 'DVAULT' }, { :value => 'OAS' }, { :value => 'OSS' }, { :value => 'CP' }, { :value => 'DBS' }, { :value => 'RISK' }, { :value => 'ACCOUNTING' }, { :value => 'ALFRED' }, { :value => 'ATP' }, { :value => 'CHASQUI' }, { :value => 'CONTRACTS' }, { :value => 'CRO' }, { :value => 'DRULES' }, { :value => 'GEO' }, { :value => 'HANDLER' }, { :value => 'SUSCRIBER' }, { :value => 'TRAVEL_AGENCY' }, { :value => 'ABACUS' }, { :value => 'COUPONS' } ].to_json
	end

	get '/config/methods' do
		content_type :json
		status 200
		[ { :value => 'GET' }, { :value => 'POST'}, { :value => 'PATCH'}, { :value => 'PUT'}, { :value => 'DELETE'} ].to_json
	end

	post '/?' do
		content_type :json
		begin
			status 200
			key = Environment.mocker.save_mock(request.body.read)
			{ :key => key }.to_json
		rescue FileNotFoundException => e
			status e.code
			{ :error => "Registro #{e.message} no encontrado. "}.to_json
		end
	end 

	post '/:key' do |key|
		content_type :json
		begin
			status 200
			key = Environment.mocker.duplicate_mock(key)
			{ :key => key }.to_json
		rescue FileNotFoundException => e
			status e.code
			{ :error => "Registro #{e.message} no encontrado. "}.to_json
		end
	end 

	put '/:key' do |key|
		content_type :json
		begin
			status 200
			key = Environment.mocker.update_mock(key, request.body.read)
			{ :key => key }.to_json
		rescue FileNotFoundException => e
			status e.code
			{ :error => "Registro #{e.message} no encontrado. "}.to_json
		end
	end 

	patch '/:key' do |key|
		content_type :json
		begin
			status 200
			json = Environment.mocker.patch_mock(key, request.body.read)
			json.to_json
		rescue FileNotFoundException => e
			status e.code
			{ :error => "Registro #{e.message} no encontrado. "}.to_json
		end
	end 

	delete '/' do
		content_type :json
		begin
			status 200
			deleted = Environment.mocker.delete_mocks(request.body.read)
			{ :deleted => deleted }.to_json
		rescue FileNotFoundException => e
			status e.code
			{ :error => "Registro #{e.message} no encontrado. "}.to_json
		end
	end 
end