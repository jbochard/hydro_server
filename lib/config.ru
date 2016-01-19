# coding: utf-8

libdir = File.dirname(__FILE__) + "/.."
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'sinatra'
require 'json'

class Environment
	class << self
		attr_accessor :config
	end
    @config = {}
end

Environment.config = JSON.parse(File.read("config/environment.json"))

load 'app.rb'

run Sinatra::Application