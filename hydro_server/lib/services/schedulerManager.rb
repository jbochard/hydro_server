# coding: utf-8

require 'rufus-scheduler'

class SchedulerManager

	def initialize(sensorsService, hydroponicService)
		@scheduler = Rufus::Scheduler.new
		@sensors = sensorsService
		@hydroponicService = hydroponicService
	end

	def start
		@scheduler.cron Environment.config["cron"] do
			begin
				@sensors.get_all("joined").each do |sensor|
					sensor.measures.each do |measure|
						value = @sensors.read_measure(sensor["url"], measure["measure"])
						measure["join"].each do |join|
							if join["type"] == "nuresery"
								@hydroponicService.register_mesurement_nursery(join["_id"], { :type => measure["measure"], :value => value })
							end
							if join["type"] == "plant"
								@hydroponicService.register_mesurement_plant(join["_id"], { :type => measure["measure"], :value => value })
							end
						end
					end
				end
			rescue Exception => e 
				puts e
			end
		end
	end

	def stop
		@scheduler.shutdown(:wait)
	end
end
