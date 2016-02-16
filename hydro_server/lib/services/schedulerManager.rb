# coding: utf-8

require 'rufus-scheduler'

class SchedulerManager

	def initialize
		@scheduler = Rufus::Scheduler.new
	end

	def start
		@scheduler.schedule_cron "*/10 * * * *", Job
	end

	def stop
		@scheduler.shutdown(:wait)
	end
end

class Job
	def execute(parameters)
		begin

		rescue Exception => e 
		end
	end
end
