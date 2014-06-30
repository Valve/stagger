$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'timecop'
require 'stagger'

RSpec.configure do |config|
  config.disable_monkey_patching!
end
