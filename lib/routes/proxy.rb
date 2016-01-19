# coding: utf-8

namespace '/proxy' do

	before do  
	    @uri = URI.parse request.url.gsub("/proxy", "")
	    @path = request.path.gsub("/proxy", "")
	  	headers['Content-Type'] = 'application/json'
	  	@debug = (! env["HTTP_X_MOCK_DEBUG"].nil?) && env["HTTP_X_MOCK_DEBUG"].upcase == 'TRUE'

		puts "[DEBUG] URL base real: #{env['HTTP_X_MOCK_PROXY_URL']}" if @debug
		puts "[DEBUG] Modulo: [#{env['HTTP_X_MOCK_MODULE']}]" if @debug		
		puts "[DEBUG] Modulos: [#{env['HTTP_X-MOCK-PROXY-CASE']}]" if @debug		

	    if ! env["HTTP_X_MOCK_PROXY_URL"].nil? && ! env["HTTP_X_MOCK_MODULE"].nil?
		    @module = env["HTTP_X_MOCK_MODULE"]
			@type = :by_pass

			proxyURI = URI.parse env["HTTP_X_MOCK_PROXY_URL"]
			@uri.scheme = proxyURI.scheme
			@uri.host = proxyURI.host
			@uri.port = proxyURI.port

			puts "[DEBUG] URL a invocar: #{@uri}" if @debug
			if ! env["HTTP_X_MOCK_MODE"].nil? && env["HTTP_X_MOCK_MODE"].upcase == 'PROXY' 
				module_case = env["HTTP_X_MOCK_PROXY_CASE"].gsub(" ", "").split(/,/) unless env["HTTP_X_MOCK_PROXY_CASE"].nil?
				@type = :proxy if module_case.nil? || module_case.include?(@module)
			end

			if ! env["HTTP_X_MOCK_MODE"].nil? && env["HTTP_X_MOCK_MODE"].upcase == 'MOCKER' 
				@list_case = env["HTTP_X_MOCK_MOCKER_CASE"].gsub(" ", "").split(";").map { |k| [ k[0..k.index("->")-1], k[k.index("->")+2..k.length-1] ] }.to_h
				@type = :mock if @list_case.has_key?(@module)
			end

			puts "[DEBUG] Modo: #{@type}" if @debug		

			env.keys
			  .select { |k| k.match("HTTP_.*") }
			  .map    { |k| k.gsub("HTTP_", "")  }
			  .each do |k| 
			    if Environment.fix_headers.has_key?(k)
			      headers[Environment.fix_headers[k]] = env["HTTP_#{k}"] 
			    else
			      headers[k.gsub("_", "-")] = env["HTTP_#{k}"] 
			    end
			  end
		else
			puts "[DEBUG] Retornando 401." if @debug			
			halt 401
		end
	end

	get '/*' do
	    body_request = "{}"
	    status_response = 200
	    case @type			
	    when :proxy then
	      begin
	        puts "Proxy: #{@module} #{@parameter} GET #{@uri}"
	        body_response = ProxyRestClient.get(@uri, headers, Environment.proxy_certs, @debug)
	        Environment.mocker.create_mock(@module, "GET", @path, body_request, body_response, status_response)
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	        Environment.mocker.create_mock(@module, "GET", @path, body_request, body_response, status_response)
	      end
	    when :by_pass then
	      begin
	        puts
	        puts "By Pass: #{@module} #{@parameter} GET #{@uri}"
	        body_response = ProxyRestClient.get(@uri, headers, Environment.proxy_certs, @debug)
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	      end	      
	    when :mock then
	      puts
	      puts "Mockeando respuesta para GET #{@uri}"
	      (status_response, body_response) = Environment.mocker.evaluate(headers, "GET", @module, @list_case, @path, "{}")
	    end
	    status status_response
	    body_response
	end

	post '/*' do
	    request.body.rewind
	    status_response = 200	    
	    body_request = request.body.read
	    if body_request == ""
	      body_request = "{}"
	    end
	    case @type
	    when :proxy then
	      begin
	        puts
	        puts "Proxy: #{@module} POST #{@uri}"
	        body_response = ProxyRestClient.post(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	        Environment.mocker.create_mock(@module, "POST", @path, headers, body_request, body_response, status_response)
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	        Environment.mocker.create_mock(@module, "POST", @path, headers, body_request, body_response, status_response)
	      end
	    when :by_pass then
	      begin
	        puts
	        puts "By Pass: #{@module} POST #{@uri}"
	        body_response = ProxyRestClient.post(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	      end	      	      
	    when :mock then
	      puts
	      puts "Mockeando respuesta para POST #{@uri}"
	      (status_response, body_response) = Environment.mocker.evaluate(headers, "POST", @module, @list_case, @path, body_request)
	    end
	    status status_response
	    body_response
	end

	put '/*' do
	    request.body.rewind
	    status_response = 200	    
	    body_request = request.body.read
	    if body_request == ""
	      body_request = "{}"
	    end
	    case @type
	    when :proxy then
	      begin
	        puts
	        puts "Proxy: #{@module} PUT #{@uri}"
	        body_response = ProxyRestClient.put(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	        Environment.mocker.create_mock(@module, "PUT", @path, body_request, body_response, status_response)
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	        Environment.mocker.create_mock(@module, "PUT", @path, body_request, body_response, status_response)	        
	      end
	    when :by_pass then
	      begin
	        puts
	        puts "Proxy: #{@module} PUT #{@uri}"
	        body_response = ProxyRestClient.put(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	       end
	    when :mock then
	      puts
	      puts "Mockeando respuesta para PUT #{@path}"
	      (status_response, body_response) = Environment.mocker.evaluate(headers, "PUT", @module, @list_case, @path, body_request)
	    end
	    status status_response
	    body_response
	end

	patch '/*' do
	    request.body.rewind
	    status_response = 200	    
	    body_request = request.body.read
	    if body_request == ""
	      body_request = "{}"
	    end
	    case @type
	    when :proxy then
	      begin
	        puts
	        puts "Proxy: #{@module} PATCH #{@uri}"
	        body_response = ProxyRestClient.patch(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	        Environment.mocker.create_mock(@module, "PATCH", @path, body_request, body_response, status_response)
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	        Environment.mocker.create_mock(@module, "PATCH", @path, body_request, body_response, status_response)
	      end
	    when :by_pass then
	      begin
	        puts
	        puts "Proxy: #{@module} PATCH #{@uri}"
	        body_response = ProxyRestClient.patch(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	       end
	    when :mock then
	      puts
	      puts "Mockeando respuesta para PATCH #{@path}"
	      (status_response, body_response) = Environment.mocker.evaluate(headers, "PATCH", @module, @list_case, @path, body_request)
	    end
	    status status_response
	    body_response
	end

	delete '/*' do
	    request.body.rewind
	    status_response = 200	    
	    body_request = request.body.read
	    if body_request == ""
	      body_request = "{}"
	    end
	    case @type
	    when :proxy then
	      begin
	        puts
	        puts "Proxy: #{@module} DELETE #{@uri}"
	        body_response = ProxyRestClient.delete(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	        Environment.mocker.create_mock(@module, "DELETE", @path, body_request, body_response, status_response)
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	        Environment.mocker.create_mock(@module, "DELETE", @path, body_request, body_response, status_response)	        
	      end
	    when :by_pass then
	      begin
	        puts
	        puts "Proxy: #{@module} DELETE #{@uri}"
	        body_response = ProxyRestClient.delete(@uri, body_request, headers, Environment.proxy_certs, @debug)  
	      rescue RestClient::Exception => e
	        puts "Headers: #{headers}"
	        puts
	        puts "Request: #{body_request}"
	        puts
	        puts "Code: #{e.http_code}"
	        puts "Response: #{e.response}"
	        puts
	        puts "Stacktrace:"
	        puts e.backtrace
	        body_response = e.response
	        status_response = e.http_code
	       end
	    when :mock then
	      puts
	      puts "Mockeando respuesta para DELETE #{@path}"
	      (status_response, body_response) = Environment.mocker.evaluate(headers, "DELETE", @module, @list_case, @path, body_request)
	    end
	    status status_response
	    body_response
	end
end