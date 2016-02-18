# coding: utf-8

require 'rufus-scheduler'

class SchedulerManager

	def initialize(sensorsService)
		@scheduler = Rufus::Scheduler.new
		@sensors = sensorsService
	end

	def start
		@scheduler.cron Environment.config["cron"] do
			begin
				@sensors.get_all("joined").each do |sensor|
					sensor.measures.each do |measure|
						value = @sensors.read_measure(sensor["url"], measure["measure"])
						puts "#{measure} = #{value}"						
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
