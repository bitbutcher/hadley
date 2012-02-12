class Hadley::TokenAccess

  def initialize(store)
    @store = store
  end

  def key_for(token)
    "afid-access-token:#{token}"
  end

  def get(token)
    access = @store.get(key_for(token))
    if access
      access[:anonymous] = access[:identity] == Hadley::ANONYMOUS_IDENTITY
    end
    access
  end

  def put(token, expires_in, data={})
    @store.set(key_for(token), data, expires_in)
  end

  def delete(token)
    @store.delete(key_for(token))
  end

end
