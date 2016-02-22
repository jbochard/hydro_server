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

require_relative 'routes/init'