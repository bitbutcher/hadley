# This mixin module provides helpful utilties for generating new authorization strategies based on configuration 
# provided when the strategy is being registered with Warden.
module Hadley::Authz::StrategyBuilder

  # Builds a new authorization strategy class based on the provided configuration.
  #
  # @param [Symbol] name The unqualified name of the authorization strategy to be built.
  # @param [Hadley::Config] config The configuration for the authorization strategy to be built.
  def build(name, config)
    strategy = self.create_strategy(name)
    self.register_strategy(name, strategy)
    self.set_config(strategy, config)
  end

  protected

  # Creates the strategy class based on the provided name.  The class will be namespaced under the class that
  # these methods are mixed into.
  #
  # @param [Symbol] name The unqualified name of the authorization strategy to be built.
  #
  # @return [Class] The new strategy class.
  def create_strategy(name)
    class_name = Hadley::Utils.camelize(name.to_s)
    if self.const_defined?(class_name)
      self.const_get(class_name) 
    else
      self.const_set(class_name, Class.new(self))
    end
  end

  # Registers the new authorization strategy with Warden under the specified name prefixed by 'afid_'.
  #
  # @param [Symbol] name The unqualified name of the authorization strategy to be built.
  # @param [Class] strategy The newly created strategy class.
  def register_strategy(name, strategy)
    full_name = "afid_#{name}".to_sym
    if Warden::Strategies[full_name].nil?
      Warden::Strategies.add(full_name, strategy) 
    end
  end

  # Binds the configuration information to the newly created strategy class.
  #
  # @param [Class] strategy The newly created strategy class.
  # @param [Hadley::Config] config The configuration to be bound to the authorization strategy.
  def set_config(strategy, config)
    strategy.const_set("CONFIG", config) unless strategy.const_defined?("CONFIG")
  end

end
