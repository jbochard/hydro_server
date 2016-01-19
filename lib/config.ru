# coding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'sinatra'
require 'json'
require 'services/implementation'
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
  i[:nurseries] = Nurseries.new
  i[:plants] 	= Plants.new
end

load 'app.rb'

run Sinatra::Application