# This module is a namespace for modules and classes related to bearer token based custom rack authorization requests
module Rack::Auth::Bearer

  # This class represents a custom rack authorization request type for bearer token based authorization
  class Request < Rack::Auth::AbstractRequest

    # Provides a means to determin if the current requests authorization type is 'Bearer'.
    #
    # @return [Boolean] true if and only if the current requests authorization type is 'Bearer'.
    def bearer?
      :bearer == scheme
    end

    # Provides access to the bearer token associated with the current request.
    #
    # @return [String] The token assiciated with the current request.
    def token
      @token ||= params.split(' ', 2).first
    end

  end

end

# This module is a namespace for modules and classes related to bearer token based authorization strategies.
module Hadley::Authz::Bearer

  
  class Strategy < Hadley::Authz::Strategy

    # Provides access to the bearer token based auth information assiciated with the current request.
    #
    # @return [Rack::Aauth::Bearer::Request] The bearer token based auth information assiciated with the current request.
    def auth
      @auth ||= Rack::Auth::Bearer::Request.new(env)
    end

    # Identifies whether a login using this strategy should be persisted across multiple requests.
    #
    # @see Warden::Strategies::Base#store?
    #
    # @return [Boolean] true if and only if a login using this strategy should be persistent across multiple requests.
    def store?
      false
    end

     # Authenticates the entity identified by the provided bearer token.
    def authenticate!(anonymous_allowed=false)
      return unauthorized unless auth.provided? and auth.bearer? and auth.token
      user = config.token_store.get(auth.token)
      return unauthorized unless user and (!user[:anonymous] or config.anonymous_allowed)
      success!(user)
    end

    private

    # Renders a custom HTTP 401 Unauthorized response with the appropriate challenge.
    def unauthorized
      custom!(Rack::Response.new([config.fail_message], 401, { 'WWW-Authenticate' => %Q{Bearer realm="#{config.realm}"} }))
    end

  end

  # This module provides the configuration extension to Warden allowing for ease of configuration for bearer token 
  # based authorization strategies via the following syntax:
  #   
  #   use Warden::Manager do |manager|
  #     manager.bearer(:server) do |bearer|
  #       bearer.token_store token_store
  #       bearer.anonymous_allowed true
  #     end
  #   end
  module ConfigExtension

    # Configures and registers and new bearer token based authorization strategy.
    #
    # @param [Symbol] name The unqualified name for the new bearer token based authorization strategy.
    # @param [Hadley::Config] config The configuration specific to the new bearer token based authorization strategy.
    def bearer(name, &block)
      config = Hadley::Config.new(
        realm: 'Access Tokens',
        fail_message: 'Authorization Failed',
        anonymous_allowed: false
      )
      if block_given?
        if block.arity == 1 
          yield config
        else
          config.instance_eval(&block)
        end
      end
      Hadley::Authz::Bearer::Strategy.build(name, config) unless config.token_store.nil?
    end
  
  end

end
