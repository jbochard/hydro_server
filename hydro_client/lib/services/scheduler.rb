# coding: utf-8

require 'json'
require 'services/scheduler'

class Scheduler

	include Singleton

	def start
		@scheduler = Thread.new do
			puts "Iniciando cron de medidas"
			lstSensors = Sensors.instance.sensors
			while true
				lstSensors.each do |sensor|
					if sensor[:type] == 'SENSOR'
						puts "Midiendo: #{sensor[:sensor]}"
						Sensors.instance.real_read(sensor[:sensor])
					end
					sleep(Environment.read_frecuency)
				end
			end			
		end
	end

	def stop
		Thread.kill(@scheduler)
	end
end
