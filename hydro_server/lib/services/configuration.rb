require 'mongo'
require 'services/exceptions'

class Configuration

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
		@mongo_client[:configuration].insert_one({ :key => "plant_code", :value => 0 }) if @mongo_client[:configuration].find({ :key => "plant_code" }).to_a.length == 0
	end

	def get_plant_code
		@mongo_client[:configuration].find({ :key => "plant_code" }).update_one({ "$inc" => { "value" => 1 } })
		@mongo_client[:configuration].find({ :key => "plant_code" }).to_a.first["value"]
	end
end