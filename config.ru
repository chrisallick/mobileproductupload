#\ -p 9299

require 'rubygems'
require 'bundler'
require 'rack/mobile-detect'

use Rack::MobileDetect

Bundler.require

require './app.rb'
run Sinatra::Application