class Hadley::TokenStore

  def initialize(store)
    @store = store
  end

  def key_for(token)
    "afid-access-token:#{token}"
  end

  def get(token)
    access = @store.read(key_for(token))
    if access
      access[:anonymous] = access[:identity] == Hadley::ANONYMOUS_IDENTITY
    end
    access
  end

  def put(token, expires_in, data={})
    @store.write(key_for(token), data, expires_in: expires_in)
  end

  def delete(token)
    @store.delete(key_for(token))
  end

end
