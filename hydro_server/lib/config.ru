# coding: utf-8

$libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift($libdir) unless $LOAD_PATH.include?($libdir)

require 'sinatra'
require 'json'
require 'json-schema'
require 'services/implementation'
require 'services/mesurements'
require 'services/configuration'
require 'services/plant_types'
require 'services/hydroponic'
require 'services/nurseries'
require 'services/plants'
require 'services/schedulerManager'
require 'services/sensors'

class Environment
	class << self
		attr_accessor :config
	end
    @config = {}
end

Environment.config = JSON.parse(File.read("config/configuration.json"))

Implementation.register do |i|
  i[:configuration] = Configuration.new
  i[:plant_types] 	= PlantTypes.new
  i[:mesurements] 	= Mesurements.new
  i[:plants] 		    = Plants.new(i[:configuration], i[:mesurements], i[:plant_types])
  i[:nurseries] 	  = Nurseries.new
  i[:sensors]       = Sensors.new(i[:nurseries], i[:plants])
  i[:hydroponic]	  = Hydroponic.new(i[:nurseries], i[:plants])
  i[:scheduler]     = SchedulerManager.new(i[:sensors])
end

Implementation[:scheduler].start

at_exit do
  Implementation[:scheduler].stop
end

load 'app.rb'

run Sinatra::Application