# coding: utf-8

require 'rufus-scheduler'
require 'mongo'
require 'json'
require 'services/exceptions'
require 'services/rulesManager'

class SchedulerManager

	def initialize(sensorsService, rulesManager)
		@scheduler = Rufus::Scheduler.new
        @mongo_client = Mongo::Client.new([ "#{Environment.config['mongodb']['host']}:#{Environment.config['mongodb']['port']}" ], :database => "#{Environment.config['mongodb']['db']}")
		@sensors = sensorsService
		@rules = rulesManager
	end

	def start
		puts "Iniciando cron de medidas"
		@scheduler.cron Environment.config["measures_cron"] do
			begin
				@sensors.get_all({ :type => 'OUTPUT' }).each do |sensor|
					measures = @sensors.read(sensor["_id"])
				end
			rescue Exception => e 
				puts e.message 
				puts e.backtrace
			end
		end

		puts "Iniciando cron de reglas"
		@scheduler.cron Environment.config["rules_cron"] do
			begin
				@rules.evaluate_active
			rescue Exception => e
				puts e.message 
				puts e.backtrace
			end
		end		
	end

	def stop
		@scheduler.shutdown(:wait)
	end
end
