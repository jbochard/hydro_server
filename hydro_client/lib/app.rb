# coding: utf-8

require 'sinatra'
require 'sinatra/namespace'

register Sinatra::Namespace

puts "Iniciando servidor..."
set :server, :thin
set :bind, '0.0.0.0'
set :run, enable

require_relative 'routes/init'