Gem::Specification.new do |s|
  s.name = "steamer"
  s.version = "0.0.0"
  s.author = "Robert Fletcher"
  s.email = "lobatifricha@gmail.com"
  s.homepage = "http://github.com/mockdeep/steamer"
  s.summary = "Steam game file backer-upper"
  s.description = "A simple Unix command line tool to back up Steam game files"

  s.files = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_dependency 'httparty'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
