
require 'mongo'
require 'hana'
require 'services/exceptions'

class Nurseries

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
        @plants = Implementation[:plants]
	end

	def get_all
        @mongo_client[:nurseries].find.projection({ _id: 1, name: 1, type: 1, creation_date: 1 }).to_a
	end

	def get(id)
		if ! exists?(id)
			raise NotFoundException.new :nursery, id
		end
        @mongo_client[:nurseries].find({:_id => BSON::ObjectId(id) }).to_a.first
	end

	def create(nursery)
		if existsByName?(nursery["name"])
			raise AlreadyExistException.new :nursery, nursery["name"]
		end
		nursery["_id"] = BSON::ObjectId.new
		nursery["creation_date"] = Date.new
		nursery["buckets"] = []
		@mongo_client[:nurseries].insert_one(nursery)
		nursery["_id"]
	end


	def set_bucket(id, position, plant_id)
		nursery = get(id)

    	# Valido que la posición sea dentro del cajón
    	if position >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
    		raise WrongIndexException.new :nursery, nursery["name"]
    	end

    	# Obtengo la planta a ingresar en el bucket
        plant = @plants.get(plant_id)

        puts plant
        # Si la planta esta en un bucket, la remuevo del bucket
        if plant["bucket"].has_key?("nursery_id")
            remove_bucket(plant["bucket"]["nursery_id"].to_s, plant["bucket"]["nursery_position"])
        end

        bucket_to_empty = nursery["buckets"].select { |b| b["position"] == position }.first
        
        # Si el bucket donde inserto la planta esta ocupado, lo remuevo
        if ! bucket_to_empty.nil?
            remove_bucket(id, position)
        end

        #inserto la planta en el bucket seleccionado
         @mongo_client[:nurseries]
            .find({ :_id => BSON::ObjectId(id) })
            .update_one({ '$push' => { :buckets => { :position => position, :plant_id => BSON::ObjectId(plant_id) } } })       
        @plants.insert_in_bucket(plant_id, id, nursery["name"], position)

        nursery["_id"]
	end

	def remove_bucket(id, position)
		nursery = get(id)

       	# Valido que la posición sea dentro del cajón
    	if position >= (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
    		raise WrongIndexException.new :nursery, nursery["name"]
    	end

        bucket_to_empty = nursery["buckets"].select { |b| b["position"] == position }.first
        puts "bucket_to_empty: #{bucket_to_empty}"
    	if ! bucket_to_empty.nil?
            @mongo_client[:nurseries]
                .find({ :_id => BSON::ObjectId(id), :buckets => { '$elemMatch' => { :position => position } } })
                .update_many({ '$pull' => { :buckets => {  :position => position  } } })

            @plants.remove_from_bucket(bucket_to_empty["plant_id"], id, position)
    	end
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

	def delete(id)
		nursery = get(id)
		@mongo_client[:nurseries].find({ :_id => BSON::ObjectId(id) }).delete_one
		nursery["_id"]
	end

	def exists?(id)
		@mongo_client[:nurseries].find({ :_id => BSON::ObjectId(id) }).to_a.length > 0
	end

    def existsByName?(name)
        @mongo_client[:nurseries].find({ :name => name }).to_a.length > 0
    end
end