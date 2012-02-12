class Hadley::Middleware < Sinatra::Base

  include Hadley::Authz

  attr_reader :confg

  def initialize(app=nil, options={})
    super(app)
    @config ||= Hadley::Config.new(options)
    yield @config if block_given?
    @tokens = @config.token_store
    self
  end

  # ------------------------------------------
  # Routes
  # ------------------------------------------

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
