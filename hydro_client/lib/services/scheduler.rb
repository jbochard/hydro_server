# coding: utf-8

require 'json'
require 'services/scheduler'

class Scheduler

	def initialize(sensors)
		@sensors = sensors
	end

	def start
		puts "Iniciando cron de medidas"
		lstSensors = @sensors.sensors
		puts lstSensors
		while true
			lstSensors.each do |sensor|
				puts sensor
				if sensor['type'] == 'SENSOR'
					puts "Midiendo: #{sensor['sensor']}"
					@sensors.real_read(sensor["sensor"])
				end
				sleep(2)
			end
		end	
	end

	def stop
	end
end
