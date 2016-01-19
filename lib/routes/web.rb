# coding: utf-8

namespace '/web' do
	get '/?' do
		content_type 'html'		    
		@host = Environment.config['web']['host']
		erb :index
	end
end