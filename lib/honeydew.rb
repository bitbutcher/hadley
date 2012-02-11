require 'honeydew/version'
require 'honeydew/authz'
require 'honeydew/token_access'
require 'sinatra/base'
require 'dalli'

module Honeydew

  class Middleware < Sinatra::Base

    set :cache, Dalli::Client.new
    disable :show_exceptions
    enable :raise_errors

    def token_store
      settings.cache
    end

    include Honeydew::Authz
    include Honeydew::TokenAccess

    configure :production, :development do
      enable :logging
    end

    put '/access/tokens/:token' do |token|
      warden.authenticate!(:afid)
      logger.info "Warden User: #{warden.user}"
      begin
        put_token(token, Integer(params.fetch('expires_in')), 
          identity: params.fetch('identity'), 
          client: params.fetch('client')
        )
        body 'Token Accepted'
      rescue => e
        status 400
        body e.to_s
      end
    end

    delete '/access/token/:token' do |token|
      warden.authenticate!(:afid)
      begin
        delete_token(token)
        body 'Token Deleted'
      rescue => e
        status 400
        body e.to_s
      end
    end

    get '/api/resources' do
      warden.authenticate!(:bearer)
      logger.info "Warden User: #{warden.user}"
      body 'This is the resource you requested'
    end

    use Rack::Session::Cookie, :secret => "somesecretkey"
    use Warden::Manager

  end

end
