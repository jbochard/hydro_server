# coding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'sinatra'
require 'json'
require 'json-schema'
require 'services/implementation'
require 'services/mesurements'
require 'services/configuration'
require 'services/hydroponic'
require 'services/nurseries'
require 'services/plants'

class Environment
	class << self
		attr_accessor :config
	end
    @config = {}
end

Environment.config = JSON.parse(File.read("config/configuration.json"))

Implementation.register do |i|
  i[:configuration] = Configuration.new
  i[:mesurements] 	= Mesurements.new
  i[:plants] 		= Plants.new(i[:configuration], i[:mesurements])
  i[:nurseries] 	= Nurseries.new
  i[:hydroponic]	= Hydroponic.new(i[:nurseries], i[:plants])
end

load 'app.rb'

run Sinatra::Application