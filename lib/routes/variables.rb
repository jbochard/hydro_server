# coding: utf-8

namespace '/variables' do

	get '/*' do
		status 200
		Environment.mocker.get_contexts(params[:query]).to_json
	end

	post '/*' do
		status 200
		request.body.rewind
	    body_request = JSON.parse(request.body.read)
		Environment.mocker.set_context(body_request["context"], body_request["key"], body_request["value"])
	    "{}".to_json
	end

	delete '/*' do
		status 200
		body = request.body.read
	    body_request = JSON.parse(body)
	    body_request.each do |l|
	   		Environment.mocker.delete_context(l)
	    end
	    "{}".to_json
	end
end