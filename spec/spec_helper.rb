require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation

  config.before(:suite) do
    FakeWeb.allow_net_connect = false
  end

  config.after(:suite) do
    FakeWeb.allow_net_connect = true
  end

end
