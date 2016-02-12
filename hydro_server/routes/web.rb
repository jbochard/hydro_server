# coding: utf-8

namespace '/web' do
	get '/?' do
		content_type 'html'		    
		@host = "#{Environment.config['web']['host']}:#{Environment.config['web']['port']}"
		erb :index
	end

	get '/main/?' do
		content_type 'html'		    
		@host = "#{Environment.config['web']['host']}:#{Environment.config['web']['port']}"
		erb :main
	end
	get '/nursery/?' do
		content_type 'html'		    
		@host = "#{Environment.config['web']['host']}:#{Environment.config['web']['port']}"
		erb :nursery
	end
end