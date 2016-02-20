# coding: utf-8

$libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift($libdir) unless $LOAD_PATH.include?($libdir)

require 'sinatra'
require 'json'
require 'mongo'
require 'json-schema'
require 'services/implementation'
require 'services/schedulerManager'
require 'services/rulesManager'
require 'services/sensors'
require 'services/parameters'

class Environment
	class << self
		attr_accessor :config
	end
    @config = {}
end

Mongo::Logger.logger       = ::Logger.new('mongo.log')
Mongo::Logger.logger.level = ::Logger::INFO

Environment.config = JSON.parse(File.read("config/configuration.json"))

Implementation.register do |i|
  i[:sensors]       = Sensors.new
  i[:parameters]    = Parameters.new
  i[:rules]         = RulesManager.new(i[:sensors], i[:parameters])
  i[:scheduler]     = SchedulerManager.new(i[:sensors], i[:rules])
end

Implementation[:scheduler].start

at_exit do
  Implementation[:scheduler].stop
end

load 'app.rb'

run Sinatra::Application