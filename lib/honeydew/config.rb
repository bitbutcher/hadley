module Honeydew

  class Config

    def initialize(config={})
      @config = config
    end

    def method_missing(name, *args, &block)
      # puts "Name: #{name}, Args: #{args}, Block: #{block}"
      if block_given?
        result = proc(name, &block)
      elsif name =~ /(.+)=$/
        result = set($1, *args, &block)
      else
        result = get(name, &block)
      end
      # puts "Result: #{result}"
      result
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
