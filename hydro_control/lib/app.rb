# coding: utf-8

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/cross_origin'

register Sinatra::Namespace
register Sinatra::CrossOrigin

puts "Iniciando servidor..."
set :server, :thin
set :bind, '0.0.0.0'
set :run, enable
enable :cross_origin

options "*" do
	response.headers["Access-Control-Allow-Methods"] 	= "GET, PUT, POST, DELETE, OPTIONS, PATCH"
	response.headers["Access-Control-Allow-Headers"] 	= "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
	200
end

require_relative 'routes/init'