# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'honeydew/version'

Gem::Specification.new do |s|
  s.name        = 'honeydew'
  s.version     = Honeydew::VERSION
  s.authors     = ['Sean M. Duncan']
  s.email       = ['bitbutcher@gmail.com']
  s.homepage    = 'https://github.com/bitbutcher/honeydew'
  s.summary     = 'Rack middleware for AFID(bby-id) resource server implementations'

  s.rubyforge_project = 'honeydew'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [ 'lib' ]

  s.add_development_dependency 'rspec'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'dalli'
end
