module Honeydew

  module Methods

    set :cache, Dalli::Client.new

    def key_for(token)
      "afid-access-token:#{token}"
    end

    def access_for(token)
      settings.cache.get(key_for(token))
    end

    def put_token(token, expires_in, **data)
      settings.cache.set(key_for(token), data, time=int(expires_in))
    end

    def delete_token(token)
      settings.cache.delete(key_for(token))
    end

  end

end
