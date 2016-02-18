
require 'services/exceptions'

class Hydroponic

	def initialize(nurseriesService, plantsService, sensorService)
        @plantsService = plantsService
        @nurseriesService = nurseriesService
        @sensorService = sensorService
	end

    def exists_nursery?(nursery_id)
        @nurseriesService.exists?(nursery_id)
    end

    def exists_by_name_nursery?(nursery_name)
        @nurseriesService.exists_by_name?(nursery_name)
    end

	def get_all_nurseries
        @nurseriesService.get_all
	end

	def get_nursery(nursery_id)
        @nurseriesService.get(nursery_id)
	end

	def create_nursery(nursery)
        @nurseriesService.create(nursery)
	end

    def update_nursery(nursery_id, nursery)
        @nurseriesService.update(nursery_id, nursery)
    end

    def delete_nursery(nursery_id)
        nursery = @nurseriesService.get(nursery_id)
        nursery["buckets"].each do |bucket|
            @plantsService.quit_plant_from_bucket(bucket["plant_id"])
        end
        @nurseriesService.delete(nursery_id)
        nursery["_id"]
    end

    def change_water_nursery(nursery_id)
        nursery = @nurseriesService.change_water(nursery_id)
        nursery_id
    end

    def fumigation_nursery(nursery_id, value)
        nursery = @nurseriesService.get(nursery_id)

        nursery["buckets"].each do |bucket|
            @plantsService.fumigation_plant(bucket["plant_id"], value)
        end
        nursery_id
    end

	def set_plant_in_bucket(plant_id, nursery_id, nursery_position)
        plant = @plantsService.get(plant_id)
        nursery = @nurseriesService.get(nursery_id)

        @plantsService.quit_plant_from_bucket(plant_id)
        if plant["bucket"].has_key?("nursery_id")
            @nurseriesService.empty_bucket(plant["bucket"]["nursery_id"], plant["bucket"]["nursery_position"])
        end

        @plantsService.insert_plant_in_bucket(plant_id, nursery_id, nursery["name"], nursery_position)
        @nurseriesService.insert_plant_in_bucket(nursery_id, nursery_position, plant_id)

        plant_id
	end

	def remove_plant_from_bucket(plant_id)
        plant = @plantsService.get(plant_id)

        @plantsService.quit_plant_from_bucket(plant_id)
        if plant["bucket"].has_key?("nursery_id")
            @nurseriesService.empty_bucket(plant["bucket"]["nursery_id"], plant["bucket"]["nursery_position"])
        end
        plant_id
    end

    def fumigation_plant(plant_id, value)
        @plantsService.fumigation_plant(plant_id, value)
    end

    def register_mesurement(nursery_id, mesurement)
        nursery = @nurseriesService.get(nursery_id)
 
        # Seteo la fecha de medición a la que se pasó u hoy
        mesurement["date"] ||= Time.new

        @nurseriesService.register_mesurement(nursery_id, mesurement)
        nursery["buckets"].each do |bucket|
            @plantsService.register_mesurement(bucket["plant_id"], mesurement)
        end
        nursery_id
    end 

    def get_all_plants
        @plantsService.get_all
    end

    def get_plant(plant_id)
        @plantsService.get(plant_id)
    end

    def create_plant(plant)
        @plantsService.create(plant)
    end

    def split_plant(plant_id)
        @plantsService.split(plant_id)
    end

    def register_growth_plant(plant_id, value)
        @plantsService.register_growth(plant_id, value)
    end

    def update_plant(plant_id, plant)
        @plantsService.update(plant_id, plant)
    end

    def delete_plant(plant_id)
        plant = @plantsService.get(plant_id)
        if plant["bucket"].has_key?("nursery_id")
            @nurseriesService.empty_bucket(plant["bucket"]["nursery_id"], plant["bucket"]["nursery_position"])
        end
        @plantsService.delete(plant_id)
    end

    def get_all_sensors
        @sensorService.get_all
    end

    def get_sensor(sensor_id)
        @sensorService.get(sensor_id)
    end

    def create_sensor(sensor_url)
        @sensorService.create(sensor_url)
    end

    def update_sensor(sensor_id, sensor)
        @sensorService.update(sensor_id, sensor)
    end

    def join_nursery_sensor(sensor_id, value)
        if ! @nurseriesService.exists?(value["nursery_id"])
            raise NotFoundException.new :nursery, value["nursery_id"]
        end
        @sensorService.join_nursery(sensor_id, value)
    end

    def join_plant_sensor(sensor_id, value)
        if ! @plantsService.exists?(value["plant_id"])
            raise NotFoundException.new :plant, value["plant_id"]
        end
        @sensorService.join_plant(sensor_id, value)
    end
end