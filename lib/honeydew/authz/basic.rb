module Honeydew
    
  module Authz

    module Basic

      class Strategy < Honeydew::Authz::Strategy

        def auth
          @auth ||= Rack::Auth::Basic::Request.new(env)
        end

        def store?
          false
        end

        def authenticate!
          return unauthorized unless auth.provided? and auth.basic? and auth.credentials
          user = config.lookup.call(auth.credentials.first, auth.credentials.last)
          return user ? success!(auth.credentials.first) : unauthorized
        end

        def unauthorized
          custom!(Rack::Response.new([config.fail_message], 401, { 'WWW-Authenticate' => %Q{Basic realm="#{config.realm}"} }))
        end

      end

      module ConfigExtension

        def basic(name, &block)
          config = Honeydew::Config.new(
            realm: 'Access Tokens',
            fail_message: 'Authorization Failed'
          )
          if block_given?
            if block.arity == 1 
              yield config
            else
              config.instance_eval(&block)
            end
          end
          Honeydew::Authz::Basic::Strategy.build(name, config) unless config.lookup.nil?
        end
      
      end

    end

  end

end

Warden::Config.send(:include, Honeydew::Authz::Basic::ConfigExtension)
