# This class is a base class for authorization strategies
class Hadley::Authz::Strategy < Warden::Strategies::Base
  extend Hadley::Authz::StrategyBuilder

  # Provides access to the configuration for this authorization strategy.
  #
  # @return [Hadley::Config] the configuration for this authorization strategy.
  def config
    self.class.const_get("CONFIG")
  end
end
