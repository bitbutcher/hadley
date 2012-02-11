# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../lib/honeydew',  __FILE__)
require 'dalli'
require 'sinatra/base'

class ToyMiddleware < Sinatra::Base
  include Honeydew::Authz
  get '/api/anon/resources' do
    warden.authenticate!(:afid_client)
    logger.info "Warden User: #{warden.user}"
    body 'This is the anonymous resource you requested'
  end
  get '/api/user/resources' do
    warden.authenticate!(:afid_user)
    logger.info "Warden User: #{warden.user}"
    body 'This is the anonymous resource you requested'
  end
  token_store = Honeydew::TokenAccess.new(Dalli::Client.new)
  use Rack::Session::Cookie, :secret => "some top secret shit"
  use Warden::Manager do |manager|
    manager.basic(:server) do |basic|
      basic.lookup do |id, secret|
        id == 'this' and secret == 'that' ? id : nil
      end
    end
    manager.bearer(:client) do |bearer|
      bearer.token_store = token_store
      bearer.anoymous_allowed = true
    end
    manager.bearer(:user) do |bearer|
      bearer.token_store = token_store
      bearer.anoymous_allowed = false
    end
  end
  use Honeydew::Middleware, token_store: token_store
end

run ToyMiddleware
