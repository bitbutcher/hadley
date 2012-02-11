module Rack::Auth::Bearer

  class Request < Rack::Auth::AbstractRequest

    def bearer?
      :bearer == scheme
    end

    def token
      @token ||= params.split(' ', 2).first
    end

  end

end

module Hadley
    
  module Authz

    module Bearer

      class Strategy < Hadley::Authz::Strategy

        def auth
          @auth ||= Rack::Auth::Bearer::Request.new(env)
        end

        def store?
          false
        end

        def authenticate!(anonymous_allowed=false)
          return unauthorized unless auth.provided? and auth.bearer? and auth.token
          user = config.token_store.get(auth.token)
          return unauthorized unless user and (!user[:anonymous] or config.anonymous_allowed)
          success!(user)
        end

        private

        def unauthorized
          custom!(Rack::Response.new([config.fail_message], 401, { 'WWW-Authenticate' => %Q{Bearer realm="#{config.realm}"} }))
        end

      end

      module ConfigExtension

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

  end

end

Warden::Config.send(:include, Hadley::Authz::Bearer::ConfigExtension)