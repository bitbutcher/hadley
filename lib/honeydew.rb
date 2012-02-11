require 'sinatra/base'
require 'warden'
require 'honeydew/version'
require 'honeydew/config'
require 'honeydew/token_access'
require 'honeydew/authz'

module Honeydew

  class Middleware < Sinatra::Base

    include Honeydew::Authz

    attr_reader :confg

    def initialize(app=nil, options={})
      super(app)
      @config ||= Honeydew::Config.new(options)
      yield @config if block_given?
      @tokens = @config.token_store
      self
    end

    # ------------------------------------------
    # Routes
    # ------------------------------------------

    put '/access/tokens/:token' do |token|
      warden.authenticate!(:afid_server)
      # logger.info "Warden User: #{warden.user}"
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

end
