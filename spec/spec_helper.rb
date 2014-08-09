require 'bundler/setup'
Bundler.setup

require File.expand_path("./lib/model_pack")

RSpec.configure do |config|
  config.color = true
end
