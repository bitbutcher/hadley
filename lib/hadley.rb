autoload :Rack, 'rack'
autoload :Sinatra, 'sinatra/base'
autoload :Warden, 'warden'

# This module is a namespace for all modules and classes related to the AFID resource server rack middleware
module Hadley

  autoload :Authz, 'hadley/authz'
  autoload :Config, 'hadley/config'
  autoload :Middleware, 'hadley/middleware'
  autoload :TokenStore, 'hadley/token_store'
  autoload :Utils, 'hadley/utils'

  # The current version of this ruby gem
  VERSION = '0.0.3'

  # The identity key for the AFID anonymous identity
  ANONYMOUS_IDENTITY = '0' * 66

end
