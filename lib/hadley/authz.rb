# This module is both a namespace for modules and classes related to AFID authorization and a collection of useful 
# helper methods that can be mixed in to application controllers / route handlers that need to interact with warden and 
# AFID authorization details.
module Hadley::Authz

  autoload :StrategyBuilder, 'hadley/authz/strategy_builder'
  autoload :Strategy, 'hadley/authz/strategy'
  autoload :Basic, 'hadley/authz/basic'
  autoload :Bearer, 'hadley/authz/bearer'

  # A wrapper method that allows cleaner access to the warden proxy
  #
  # @return [Warden::Proxy] The warden lazy object equivalent to <tt>env['warden']</tt>.
  def warden
    env['warden']
  end

  # Add the warden config extension for the Basic authorization strategy
  Warden::Config.send(:include, Hadley::Authz::Basic::ConfigExtension)
  # Add the warden config extension for the Bearer authorization strategy
  Warden::Config.send(:include, Hadley::Authz::Bearer::ConfigExtension)

end
