# coding: utf-8

namespace '/web' do
	get '/?' do
		content_type 'html'		    
		@host = Environment.values['host']
		@proxy = Environment.values['proxy']
		erb :index
	end

	get '/mocks-tab/?' do
		content_type 'html'		    
		@host = Environment.values['host']
		@proxy = Environment.values['proxy']
		erb :mocksTabs
	end

	get '/variables-tab/?' do
		content_type 'html'		    
		@host = Environment.values['host']
		@proxy = Environment.values['proxy']
		erb :variableTabs
	end
end