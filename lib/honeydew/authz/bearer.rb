require 'warden'

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

module Honeydew
    
  module Authz

    class Bearer < Warden::Strategies::Base

      def auth
        @auth ||= Rack::Auth::Bearer::Request.new(env)
      end

      def store?
        false
      end

      def authenticate!
        auth.provided? and auth.bearer? and auth.token and check_token(auth.token) or unauthorized
      end

      private

      def check_token(token)
        puts "Token: #{token}"
        success! token
      end

      def unauthorized
        custom!(Rack::Response.new([], 401, { 'WWW-Authenticate' => 'Bearer realm="Restricted Area"' }))
      end

    end

    Warden::Strategies.add(:bearer, Honeydew::Authz::Bearer)

  end

end
