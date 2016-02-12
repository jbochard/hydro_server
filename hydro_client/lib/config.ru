# coding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'sinatra'
require 'json'
require 'json-schema'
require 'services/sensors'


class Environment
	class << self
		attr_accessor :config
	end
    @config = {}
end

Environment.config = JSON.parse(File.read("config/configuration.json"))

Implementation.register do |i|
  i[:sensors] 	     = Sensors.new
end

load 'app.rb'

run Sinatra::Application