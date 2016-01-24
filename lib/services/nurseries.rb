
require 'mongo'
require 'hana'
require 'services/exceptions'

class Nurseries

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

    def exists?(nursery_id)
        @mongo_client[:nurseries].find({ :_id => BSON::ObjectId(nursery_id) }).to_a.length > 0
    end

    def exists_by_name?(nursery_name)
        @mongo_client[:nurseries].find({ :name => nursery_name }).to_a.length > 0
    end

	def get_all
        @mongo_client[:nurseries].find.projection({ _id: 1, name: 1, type: 1, creation_date: 1 }).to_a
	end

	def get(nursery_id)
		if ! exists?(nursery_id)
			raise NotFoundException.new :nursery, nursery_id
		end
        @mongo_client[:nurseries].find({ :_id => BSON::ObjectId(nursery_id) }).to_a.first
	end

	def create(nursery)
		if exists_by_name?(nursery["name"])
			raise AlreadyExistException.new :nursery, nursery["name"]
		end
		nursery["_id"] = BSON::ObjectId.new
		nursery["creation_date"] = Time.new
		nursery["buckets"] = []
		@mongo_client[:nurseries].insert_one(nursery)
		nursery["_id"]
	end

    def delete(nursery_id)
        if ! exists?(nursery_id)
            raise NotFoundException.new :nursery, nursery_id
        end
        @mongo_client[:nurseries].find({ :_id => BSON::ObjectId(nursery_id) }).delete_one
        nursery_id
    end

    def empty_bucket(nursery_id, nursery_position)
        nursery = get(nursery_id)

        # Valido que la posición sea dentro del cajón
        if nursery_position >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
            raise WrongIndexException.new :nursery, nursery["name"]
        end

        @mongo_client[:nurseries]
            .find({ :_id => BSON::ObjectId(nursery_id), :buckets => { '$elemMatch' => { :position => nursery_position } } })
            .update_many({ '$pull' => { :buckets => {  :position => nursery_position  } } })
        nursery_id
    end

	def insert_plant_in_bucket(nursery_id, nursery_position, plant_id)
		nursery = get(nursery_id)

    	# Valido que la posición sea dentro del cajón
     	if nursery_position >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
    		raise WrongIndexException.new :nursery, nursery["name"]
    	end

        #inserto la planta en el bucket seleccionado
         @mongo_client[:nurseries]
            .find({ :_id => BSON::ObjectId(nursery_id) })
            .update_one({ '$push' => { :buckets => { :position => nursery_position, :plant_id => BSON::ObjectId(plant_id) } } })       
 
        nursery["_id"]
	end

	def set_mesurement(id, mesurement)
		nursery = get(id)
 
    	# Seteo la fecha de medición a la que se pasó u hoy
    	mesurement["date"] ||= Date.new

    	# Seteo la medición en el cajón
        patch = Hana::Patch.new [ { "op" => "replace", 	"path" => "/last_mesurement", "value" => mesurement } ]
        nursery = patch.apply(nursery)
        @mongo_client[:nurseries].find({ :_id => BSON::ObjectId(id) }).replace_one(nursery)

        # Agrego la última medición al cajón y agrego la medición en cada planta del cajón.
        nursery["buckets"].each do |pos, bucket|
            plant_id = bucket["plant_id"]
            @plants.add_mesurement(plant_id, mesurement)
        end
	    nursery["_id"]
	end
end