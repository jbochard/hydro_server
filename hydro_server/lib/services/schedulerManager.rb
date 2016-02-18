# coding: utf-8

require 'rufus-scheduler'

class SchedulerManager

	def initialize(sensorsService)
		@scheduler = Rufus::Scheduler.new
		@sensors = sensorsService
	end

	def start
		@scheduler.cron Environment.config["measures_cron"] do
			begin
				@sensors.get_all.each do |sensor|
					measures = @sensors.read(sensor["_id"])
				end
			rescue Exception => e 
				puts e
			end
		end

		@scheduler.cron Environment.config["rules_cron"] do
			begin
				
			rescue Exception => e 
				puts e
			end
		end		
	end

	def stop
		@scheduler.shutdown(:wait)
	end
end
