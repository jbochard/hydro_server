# coding: utf-8

namespace '/hosts' do
	get '' do
		content_type :json
		list_hosts = read_to_hash('/etc/hosts')
		status 200
		list_hosts.to_json
	end

	post '' do
		content_type :json
		list_hosts = read_to_hash('/etc/hosts')
		json = JSON.parse(request.body.read)
		list_hosts[json["key"]] = json["value"]
		write_from_hash('/etc/hosts', list_hosts)
		status 200
	end 

	delete '/:key' do |key|
		content_type :json
		list_hosts = read_to_hash('/etc/hosts')
		if list_hosts.delete(key).nil?
			status 404
			{ :error => "No existe host #{key}. "}.to_json
		else
			status 200
			write_from_hash('/etc/hosts', list_hosts)
		end
	end 

	private
	def read_to_hash(file)
		hosts = File.read(file)
		list_hosts = Hash.new
		hosts.each_line do |line|
			line = line.chomp.gsub(/^\s+/, '').gsub(/\t/, ' ')
			if ! line.match("#.*") && line.length > 0
				reg = line.split(/\s+/)
				key = reg.shift
				val = reg.join(" ")
				if list_hosts.has_key?(key)
					list_hosts[key] = list_hosts[key] + " " + val
				else
					list_hosts[key] = val
				end
			end
		end
		list_hosts
	end

	def write_from_hash(file, hash)
		buffer = ""
		hash.keys.each do |k|
			line = "#{k} #{hash[k]}"
			buffer = buffer + line + "\n"
		end
		File.write(file, buffer) 
	end
end