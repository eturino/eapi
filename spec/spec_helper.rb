require 'bundler/setup'
Bundler.setup

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'pry'
require 'eapi'

RSpec.configure do |config|
  # some (optional) config here
end
