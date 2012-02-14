# This class provides the rack middleware that builds on top of warden to provide the necessary endpoints for a rack 
# application to function as an AFID protected resource.
class Hadley::Middleware < Sinatra::Base

  include Hadley::Authz

  # Initializes the middleware with the provided application and options
  #
  # @param [Rack::Application] app The rack application that this middleware is participating in
  # @param [Hash] options The Hash of keyword arguments
  # @param [Hadley::TokenStore] options.store The token store to be used for persisting tokens provisioned by the AFID
  #  authorization server
  def initialize(app=nil, options={})
    super(app)
    @config ||= Hadley::Config.new(options)
    yield @config if block_given?
    @tokens = @config.token_store
    self
  end

  # The required endpoint for provisioning AFID access tokens.
  put '/access/tokens/:token' do |token|
    warden.authenticate!(:afid_server)
    begin
      @tokens.put(token, Integer(params.fetch('expires_in')), 
        identity: params.fetch('identity'), 
        client: params.fetch('client')
      )
      body 'Token Accepted'
    rescue => e
      status 400
      body e.to_s
    end
  end

  # The required endpoint for invalidating AFID access tokens.
  delete '/access/tokens/:token' do |token|
    warden.authenticate!(:afid_server)
    begin
      @tokens.delete(token)
      body 'Token Deleted'
    rescue => e
      status 400
      body e.to_s
    end
  end

  # ------------------------------------------
  # Config
  # ------------------------------------------

  disable :show_exceptions
  enable :raise_errors
  enable :logging

end
