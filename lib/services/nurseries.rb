
require 'mongo'
require 'hana'
require 'services/exceptions'

class Nurseries

	def initialize
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
	end

    def exists?(nursery_id)
        @mongo_client[:nurseries].find({ :_id => nursery_id }).to_a.length > 0
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
        nursery = @mongo_client[:nurseries].find({ :_id => nursery_id }).to_a.first
        nursery["time_change_water"] = ((Time.new - nursery["water_events"].map { |r| r["date"] }.max).to_i / 86400).floor if nursery.has_key?("water_events")
        nursery
	end

	def create(nursery)
		if exists_by_name?(nursery["name"])
			raise AlreadyExistException.new :nursery, nursery["name"]
		end
		nursery["_id"] = BSON::ObjectId.new.to_s
		nursery["creation_date"] = Time.new
		nursery["buckets"] = []
        nursery["dimensions"]["length"] = 1 if nursery["type"] == "plantpot"
        nursery["dimensions"]["width"]  = 1 if nursery["type"] == "plantpot"
		@mongo_client[:nurseries].insert_one(nursery)
		nursery["_id"]
	end

    def update(nursery_id, nursery)
        if ! exists?(nursery_id)
            raise NotFoundException.new :nursery, nursery_id
        end
         @mongo_client[:nurseries]
            .find({ :_id => nursery_id })
            .update_one({ '$set' => { :name => nursery["name"], :type => nursery["type"], :description => nursery["description"] } })
    end

    def delete(nursery_id)
        if ! exists?(nursery_id)
            raise NotFoundException.new :nursery, nursery_id
        end
        @mongo_client[:nurseries].find({ :_id => nursery_id }).delete_one
        nursery_id
    end

    def change_water(nursery_id)
        if ! exists?(nursery_id)
            raise NotFoundException.new :nursery, nursery_id
        end
        #inserto el registro de cambio de agua
         @mongo_client[:nurseries]
            .find({ :_id => nursery_id })
            .update_one({ '$push' => { :water_events => { :date => Time.new } } })               
    end        

    def empty_bucket(nursery_id, nursery_position)
        nursery = get(nursery_id)

        # Valido que la posición sea dentro del cajón
        if nursery_position > (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
            raise WrongIndexException.new :nursery, nursery["name"]
        end

        @mongo_client[:nurseries]
            .find({ :_id => nursery_id, :buckets => { '$elemMatch' => { :position => nursery_position } } })
            .update_many({ '$pull' => { :buckets => {  :position => nursery_position  } } })
        nursery_id
    end

	def insert_plant_in_bucket(nursery_id, nursery_position, plant_id)
		nursery = get(nursery_id)

    	# Valido que la posición sea dentro del cajón
     	if nursery_position > (nursery["dimensions"]["length"] * nursery["dimensions"]["width"])
    		raise WrongIndexException.new :nursery, nursery["name"]
    	end

        #inserto la planta en el bucket seleccionado
         @mongo_client[:nurseries]
            .find({ :_id => nursery_id })
            .update_one({ '$push' => { :buckets => { :position => nursery_position, :plant_id => plant_id } } })       
 
        nursery["_id"]
	end

	def register_last_mesurement(nursery_id, mesurement)
		nursery = get(nursery_id)
        @mongo_client[:nurseries].find({ :_id => nursery_id }).update_one({ "$set" => { :last_mesurement => mesurement } } )
	    nursery_id
	end
end