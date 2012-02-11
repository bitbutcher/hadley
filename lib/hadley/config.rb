module Hadley

  class Config

    def initialize(config={})
      @config = config
    end

    def method_missing(name, *args, &block)
      if block_given?
        proc(name, &block)
      elsif name =~ /(.+)=$/
        set($1, *args, &block)
      else
        get(name, &block)
      end
    end

    def proc(name, &block)
      @config[name.to_sym] = block
    end

    def set(name, *args)
      @config[name.to_sym] = args.size == 1 ? args.first : args
    end

    def get(name, &block)
      @config[name.to_sym]
    end

  end
	
end
