module Hadley::Authz

  autoload :Basic, 'hadley/authz/basic'
  autoload :Bearer, 'hadley/authz/bearer'

  def warden
    env['warden']
  end

  module StrategyBuilder

    def build(name, config)
      strategy = self.create_strategy(name)
      self.register_strategy(name, strategy)
      self.set_config(strategy, config)
    end

    protected

    def create_strategy(name)
      class_name = Hadley::Utils.camelize(name.to_s)
      if self.const_defined?(class_name)
        self.const_get(class_name) 
      else
        self.const_set(class_name, Class.new(self))
      end
    end

    def register_strategy(name, strategy)
      full_name = "afid_#{name}".to_sym
      if Warden::Strategies[full_name].nil?
        Warden::Strategies.add(full_name, strategy) 
      end
    end

    def set_config(strategy, config)
      strategy.const_set("CONFIG", config) unless strategy.const_defined?("CONFIG")
    end

  end

  class Strategy < Warden::Strategies::Base
    extend StrategyBuilder

    def config
      self.class.const_get("CONFIG")
    end
  end

  Warden::Config.send(:include, Hadley::Authz::Basic::ConfigExtension)
  Warden::Config.send(:include, Hadley::Authz::Bearer::ConfigExtension)

end
