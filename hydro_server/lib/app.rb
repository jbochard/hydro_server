# coding: utf-8

require 'sinatra'
require 'sinatra/namespace'

register Sinatra::Namespace

puts "Iniciando servidor..."
set :server, :thin
set :bind, '0.0.0.0'
set :run, enable
set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views,         File.join(File.dirname(__FILE__), 'views')    

puts "Acceda al servidor web a traves de: #{Environment.config['web']['host']}/web"

require_relative 'routes/init'