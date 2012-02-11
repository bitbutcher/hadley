module Honeydew::TokenAccess

  def key_for(token)
    "afid-access-token:#{token}"
  end

  def access_for(token)
    token_store.get(key_for(token))
  end

  def put_token(token, expires_in, data={})
    token_store.set(key_for(token), data, expires_in)
  end

  def delete_token(token)
    token_store.delete(key_for(token))
  end

end
