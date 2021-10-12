# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'point'

use Rack::Reloader, 1

run Point
