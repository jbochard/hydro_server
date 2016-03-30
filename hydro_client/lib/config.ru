# coding: utf-8

$libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift($libdir) unless $LOAD_PATH.include?($libdir)

require 'sinatra'
require 'json'
require 'json-schema'
require 'services/sensors'
require 'services/scheduler'

class Environment
	class << self
		attr_accessor :config, :sensors, :debug, :read_frecuency
	end
    @config = {}
    @sensors = {}
    @debug = false
    @read_frecuency = 2

    def self.load(file)
    	@config = JSON.parse(File.read("config/configuration.json"))
    	@debug = @config['debug']
    	@read_frecuency = @config['read_frecuency']
    end
end

Environment.load("config/configuration.json")

load 'app.rb'

run Sinatra::Application

Scheduler.instance.start

at_exit do
  Scheduler.instance.stop
end
