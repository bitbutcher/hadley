# This module is a namespace for modules and classes related to the HTTP Basic authorization strategy.
module Hadley::Authz::Basic

  # This class is the prototype class for all HTTP Basic authorization strategies used by hadley.
  class Strategy < Hadley::Authz::Strategy

    # Provides access to the HTTP Basic Auth information assiciated with the current request.
    #
    # @return [Rack::Aauth::Basic::Request] The HTTP Basic Auth information associated with the current request.
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(env)
    end

    # Identifies whether a login using this strategy should be persisted across multiple requests.
    #
    # @see Warden::Strategies::Base#store?
    #
    # @return [Boolean] true if and only if a login using this strategy should be persistent across multiple requests.
    def store?
      false
    end

    # Authenticates the entity identified by the provided HTTP Basic Auth information
    def authenticate!
      return unauthorized unless auth.provided? and auth.basic? and auth.credentials
      credentials = auth.credentials.map do |credential|
        config.hash_credentials ? Digest::SHA2.new(256).update(credential).to_s : credential
      end
      user = config.lookup.call(credentials.first, credentials.last)
      return user ? success!(auth.credentials.first) : unauthorized
    end

    private

    # Renders a custom HTTP 401 Unauthorized response with the appropriate challenge.
    def unauthorized
      custom!(Rack::Response.new([config.fail_message], 401, { 'WWW-Authenticate' => %Q{Basic realm="#{config.realm}"} }))
    end

  end

  # This module provides the configuration extension to Warden allowing for ease of configuration for basic auth 
  # strategies via the following syntax:
  #   
  #   use Warden::Manager do |manager|
  #     manager.basic(:server) do |basic|
  #       basic.hash_credentials true
  #       basic.lookup do |id, secret|
  #         [ id, secret] == [ 'client_identity', 'client_secret' ] ? id : nil
  #       end
  #     end
  #   end
  module ConfigExtension

    # Configures and registers and new basic authorization strategy.
    #
    # @param [Symbol] name The unqualified name for the new basic authorization strategy.
    # @param [Hadley::Config] config The configuration specific to the new basic authorization strategy.
    def basic(name, &block)
      config = Hadley::Config.new(
        realm: 'Access Tokens',
        fail_message: 'Authorization Failed',
        hash_credentials: false
      )
      if block_given?
        if block.arity == 1 
          yield config
        else
          config.instance_eval(&block)
        end
      end
      Hadley::Authz::Basic::Strategy.build(name, config) unless config.lookup.nil?
    end
  
  end

end
