# This file is used by Rack-based servers to start the application.
require 'rubygems'
require 'hadley'
require 'dalli'
require 'sinatra/base'
require 'json'

class ExampleResourceServer < Sinatra::Base
  include Hadley::Authz

  get '/' do
    body 'afid-resource-server'
  end

  get '/v1/current_time' do
    warden.authenticate!(:afid_user)
    body({current_time: Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')}.to_json)
  end

  get '/v1/anonymous_time' do
    warden.authenticate!(:afid_client)
    body({current_time: Time.now.strftime('%s')}.to_json)
  end

  token_store = Hadley::TokenAccess.new(Dalli::Client.new)

  use Rack::Session::Cookie, :secret => 'a8ab10237100f16d12b6c8e574e84b92cc15aecaced04d47251a5f34ffaa0e60'

  use Warden::Manager do |manager|
    manager.basic(:server) do |basic|
      basic.hash_credentials = true
      basic.lookup do |id, secret|
        [ id, secret] == [
          'a8ab10237100f16d12b6c8e574e84b92cc15aecaced04d47251a5f34ffaa0e60',
          '29cd5d3e8f481821422f886055d536c8e395a8aa123700eec74f045b0144e986'
        ] ? id : nil
      end
    end
    manager.bearer(:client) do |bearer|
      bearer.token_store = token_store
      bearer.anonymous_allowed = true
    end
    manager.bearer(:user) do |bearer|
      bearer.token_store = token_store
      bearer.anonymous_allowed = false
    end
  end

  use Hadley::Middleware, token_store: token_store
end

run ExampleResourceServer
