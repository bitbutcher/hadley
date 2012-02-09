require 'honeydew/version'
require 'honeydew/methods'
require 'sinatra'
require 'dalli'
require 'base64'

module Honeydew

  class Middleware < Sinatra::Base

    include Honeydew::Methods

    def check_credentials(id, secret)
      puts "Id: #{id}, Secret: #{secret}"
      true
    end

    before '/access/token/*' do
      begin
        authorization = request['Authorization']
        type, digest = authorization.split(' ', 1)
        id, secret = Base64.decode64(digest).split(':', 1)
        raise Exception unless check_credentials(id, secret)
      rescue Exception => e
        halt 401, { 'WWW-Authenticate' => %Q{Basic realm="#{realm}"} }, ''
      end
    end

    put '/access/token/:token' do |token|
      begin
        put_token(token, Integer(params.fetch(:expires_in)), 
          identity: params.fetch(:identity), 
          client: params.fetch(:client)
        )
        body 'Token Accepted'
      rescue => e
        status 400
        body e.to_s
      end
    end

    delete '/access/token/:token' do |token|
      begin
        delete_token(token)
        body 'Token Deleted'
      rescue => e
        status 400
        body e.to_s
      end
    end

  end

end
