$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)



require 'simplecov'
SimpleCov.start

# require 'emony'

if RSpec.configuration.instance_variable_get(:@files_or_directories_to_run) == %w(spec)
  Dir["#{__dir__}/../lib/**/*.rb"].map do |x|
    require x
  end
end
