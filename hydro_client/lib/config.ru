# coding: utf-8

$libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift($libdir) unless $LOAD_PATH.include?($libdir)

require 'sinatra'
require 'json'
require 'json-schema'
require 'services/sensors'
require 'services/sensorMock'
require 'services/implementation'


class Environment
	class << self
		attr_accessor :config, :sensors
	end
    @config = {}
    @sensors = {}
end

Environment.config  = JSON.parse(File.read("config/configuration.json"))
Environment.sensors = JSON.parse(File.read("#{$libdir}/config.json"))

Implementation.register do |i|
  i[:sensors] 	     = (Environment.config.has_key?('test') && Environment.config['test'])? SensorMock.new: Sensors.new
end

load 'app.rb'

run Sinatra::Application