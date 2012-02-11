module Hadley
    
  module Authz

    module Basic

      class Strategy < Hadley::Authz::Strategy

        def auth
          @auth ||= Rack::Auth::Basic::Request.new(env)
        end

        def store?
          false
        end

        def authenticate!
          return unauthorized unless auth.provided? and auth.basic? and auth.credentials
          credentials = auth.credentials.map do |credential|
            config.hash_credentials ? Digest::SHA2.new(256).update(credential).to_s : credential
          end
          user = config.lookup.call(credentials.first, credentials.last)
          return user ? success!(auth.credentials.first) : unauthorized
        end

        def unauthorized
          custom!(Rack::Response.new([config.fail_message], 401, { 'WWW-Authenticate' => %Q{Basic realm="#{config.realm}"} }))
        end

      end

      module ConfigExtension

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

  end

end

Warden::Config.send(:include, Hadley::Authz::Basic::ConfigExtension)
