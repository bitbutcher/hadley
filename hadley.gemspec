# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'hadley'

Gem::Specification.new do |s|
  s.name        = 'hadley'
  s.version     = Hadley::VERSION
  s.authors     = ['Sean M. Duncan']
  s.email       = ['bitbutcher@gmail.com']
  s.homepage    = 'https://github.com/bitbutcher/hadley'
  s.summary     = 'Rack middleware for AFID(bby-id) resource server implementations'

  s.rubyforge_project = 'hadley'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [ 'lib' ]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'active_support'
  s.add_development_dependency 'dalli'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'warden'
end
