require 'warden'

module Honeydew
    
  module Authz

    class Afid < Warden::Strategies::Base

      def auth
        @auth ||= Rack::Auth::Basic::Request.new(env)
      end

      def store?
        false
      end

      def authenticate!
        auth.provided? and auth.basic? and auth.credentials and check_credentials(
          auth.credentials.first, 
          auth.credentials.last
        ) or unauthorized
      end

      private

      def check_credentials(id, secret)
        puts "Id: #{id}, Secret: #{secret}"
        success! id
      end

      def unauthorized
        custom!(Rack::Response.new([], 401, { 'WWW-Authenticate' => 'Basic realm="AccessTokens"' }))
      end

    end

    Warden::Strategies.add(:afid, Honeydew::Authz::Afid)

  end

end
