# coding: utf-8

require 'rufus-scheduler'

class SchedulerManager

	def initialize(nurseriesService, sensorsService)
		@scheduler = Rufus::Scheduler.new
		@nurseries = nurseriesService
		@sensors = sensorsService
	end

	def start
		@scheduler.cron "*/1 * * * *" do
			begin
				@nurseries.get_all('client').each do |reg|
					if reg.has_key?("client_url")
						@sensors.get_measures(reg["client_url"]).each do |measure|
							value = @sensors.read_measure(reg["client_url"], measure)
							puts "#{measure} = #{value}"
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
