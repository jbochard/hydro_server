
require 'mongo'
require 'hana'
require 'services/exceptions'

class Nurseries

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

	def get_all
        @mongo_client[:nurseries].find.projection({ _id: 1, name: 1, dimensions: 1, creation_date: 1 }).to_a
	end

	def get(name)
		if ! exists?(name)
			raise NotFoundException.new :nursery, name
		end
        @mongo_client[:nurseries].find({:name => name }).to_a.first
	end

	def create(nursery)
		if exists?(nursery["name"])
			raise AlreadyExistException.new :nursery, nursery["name"]
		end
		nursery["_id"] = BSON::ObjectId.new
		nursery["creation_date"] = Date.new
		nursery["buckets"] = {}
		@mongo_client[:nurseries].insert_one(nursery)
		nursery["_id"]
	end

	def update(name, operation)
		nursery = get(name)
 
		case operation["op"].upcase
		when "ADD_BUCKET"
			pos = operation['value']['position']
            if nursery["buckets"][pos].nil?
            	# Valido que la posición sea dentro del cajón
	        	if pos >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
	        		raise WrongIndexException.new :nursery, name
	        	end
	        	# Valido que la planta exista
	        	plant_id = operation["value"]["plant_id"]
	        	if ! Implementation[:plants].exists?(plant_id)
	        		raise NotFoundException.new :plant, plant_id
	        	end
	        	# Agrega la planta al cajón
	        	operation["value"]["plant_id"] = BSON::ObjectId.from_string(plant_id)
	        	patch = Hana::Patch.new [ { "op" => "add", 	"path" => "/buckets/-", "value" => operation["value"] } ]
	        else
            	# Valido que la posición sea dentro del cajón
	        	if pos >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
	        		raise WrongIndexException.new :nursery, name
	        	end
	        	# Valido que la planta exista
	        	plant_id = operation["value"]["plant_id"]
	        	if ! Implementation[:plants].exists?(plant_id)
	        		raise NotFoundException.new :plant, plant_id
	        	end
	        	# reemplazo la planta en el cajón
	        	operation["value"]["plant_id"] = BSON::ObjectId.from_string(plant_id)
	        	patch = Hana::Patch.new [ { "op" => "replace", "path" => "/buckets/#{pos}", "value" => operation["value"] } ]
	        end
	    when "REMOVE_BUCKET"
           	# Valido que la posición sea dentro del cajón
        	if operation["value"]["position"] >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
        		raise WrongIndexException.new :nursery, name
        	end
	        patch = Hana::Patch.new [ { "op" => "remove", "path" => "/buckets/#{operation['value']}" } ]
	    when "SET_MEASUREMENT"
	    	# Seteo la fecha de medición a la que se pasó u hoy
	    	operation["value"]["date"] ||= Date.new
	    	# Seteo la medición en el cajón
	        patch = Hana::Patch.new [ { "op" => "replace", 	"path" => "/measurement", "value" => operation["value"] } ]
	        # Agrego la última medición al cajón y agrego la medición en cada planta del cajón.
	        Implementation[:plants].add_measurement(nursery["buckets"], operation["value"])
	    else
	    	raise WrongOperationException.new :nursery, name, [ "ADD_BUCKET", "REMOVE_BUCKET", "SET_MEASUREMENT" ] 
		end
        nursery = patch.apply(nursery)
        @mongo_client[:nurseries].find({ :name => name }).replace_one(nursery)
        nursery["_id"]
	end

	def delete(name)
		nursery = get(name)
		@mongo_client[:nurseries].delete({ :name => name })
		nursery["_id"]
	end

	def exists?(name)
		@mongo_client[:nurseries].find({ :name => name }).to_a.length > 0
	end
end