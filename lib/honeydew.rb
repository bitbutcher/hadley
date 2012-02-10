require 'honeydew/version'
require 'honeydew/token_access'
require 'sinatra'
require 'dalli'
require 'modularity'

module Honeydew

  class Middleware < Sinatra::Base

    set :cache, Dalli::Client.new

    include Honeydew::TokenAccess

    configure :production, :development do
      enable :logging
    end

    def check_credentials(id, secret)
      logger.info "Id: #{id}, Secret: #{secret}"
      true
    end

    before '/access/tokens/*' do
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      unless @auth.provided? and @auth.basic? and @auth.credentials and check_credentials(@auth.credentials[0], @auth.credentials[1])
        halt 401, { 'WWW-Authenticate' => 'Basic realm="AccessTokens"' }, ''
      end
    end

    put '/access/tokens/:token' do |token|
      begin
        logger.info "Params: #{params}"
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
      begin
        delete_token(token)
        body 'Token Deleted'
      rescue => e
        status 400
        body e.to_s
      end
    end

  end

end
