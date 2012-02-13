# This class handles the storage, retrieval and removal of OAuth 2 bearer tokens sent from the AFID authorization 
# server. The TokenStore delegates most of the work to the delegate store, which must support the api set forth by
# ActiveSupport::Cache::Store.
class Hadley::TokenStore

  # This method initializes the TokenStore with the delegate store.
  #
  # @param [ActiveSupport::Cache::Store] store The TokenStore instance will delegate the heavy lifting to the provided 
  #  store.
  def initialize(store)
    @store = store
  end

  # This method retrieves the AFID identity information associated with the provided token.  If no such identity is 
  # found the result will be nil.
  #
  # @param [String] token The unique token provisioned by the AFID resource server.
  #
  # @return [Hash, nil] A Hash representation of the identity associated with the provided token or nil if no such identity
  #  exists.
  def get(token)
    access = @store.read(key_for(token))
    if access
      access[:anonymous] = access[:identity] == Hadley::ANONYMOUS_IDENTITY
    end
    access
  end

  # This method stores the provided AFID identity information under the given AFID token for the duration of time
  # specified by the expires_in argument.
  # 
  # @param [String] token The unique token provisioned by the AFID resource server.
  # @param [Integer] expires_in The duration of time (in seconds) that the provided AFID identity information should be 
  #  stored.
  # @param [Hash] data The identity information to be assiciated with the given AFID token.
  #
  # @return [Boolean, nil] True if and only if the identity information was stored successfully.
  def put(token, expires_in, data={})
    @store.write(key_for(token), data, expires_in: expires_in)
  end

  # This method removes the AFID identity information associated with the provided token.
  #
  # @param [String] token The token provisioned by the AFID resource server.
  #
  # @return [Boolean, nil] True if an only if the identity information was removed successfully.
  def delete(token)
    @store.delete(key_for(token))
  end

  protected

  # This method derives the appropriate datastore key from the given AFID token.
  #
  # @param [String] token The unique token provisioned by the AFID resource server.
  #
  # @return [Symbol] The appropriate datastore key for the given AFID token.
  def key_for(token)
    "afid-access-token:#{token}".to_sym
  end

end
