autoload :Rack, 'rack'
autoload :Sinatra, 'sinatra/base'
autoload :Warden, 'warden'

module Hadley

  autoload :Authz, 'hadley/authz'
  autoload :Config, 'hadley/config'
  autoload :Middleware, 'hadley/middleware'
  autoload :TokenStore, 'hadley/token_store'
  autoload :Utils, 'hadley/utils'

  VERSION = '0.0.1'

  ANONYMOUS_IDENTITY = '0' * 66

end
