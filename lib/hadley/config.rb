# This class is a convenience wrapper around an Hash that provides a more expressive api for initial configuration and
# referencing the configuration information at runtime.  For example:
#   config.prop 'value' # --> config[:prop] = 'value'
#   config.prop = 'value' # --> same as above
#   config.props 'a', 'b', 'c' # --> config[:props] = [ 'a', 'b', 'c' ]
#   config.props = 'a', 'b', 'c' # same as above
#   config.callback { |it| puts it } # config[:callback] = { |it| puts it }
#   config.prop # --> config[:prop]
class Hadley::Config

  # Initializes this Config with the specified defaults.
  #
  # @param [Hash] defaults The default configuration values for this Config instance.
  def initialize(defaults={})
    @config = defaults
  end

  # Delegates to {#set}, {#get} or {#proc} depending on the nature of the given name, if a block is given or if the args
  # array is not empty.
  # 
  # @param [String] name The name of the property to be read or written.  If the name ends with '=' it will be stripped
  #  from the name and the operation will be treated as a write.
  # @param [*Object] args The optional array of property values to be assigned to the provided property name.  If this
  #  array is not empty then {#set} will be called.
  # @param [Proc] &block The optional block to be assigned to the provided property name. If the operation has a block 
  #  given then {#proc} will be called.
  #
  # @return [Object,nil] The value ultimately written to or read from the given property name.
  def method_missing(name, *args, &block)
    if block_given?
      proc(name, &block)
    elsif name =~ /(.+)=$/
      set($1, *args)
    elsif not args.empty?
      set(name, *args)
    else
      get(name)
    end
  end

  # Stores the given block under the provided property name.
  #
  # @param [String] name The name of the property to be written.
  # @param [Proc] &block The block to be assigned to the provided property name.
  #
  # @return [Proc] The block written to the provided name.
  def proc(name, &block)
    @config[name.to_sym] = block
  end

  # Stores the value or values indicated by the args array under the provided property name.
  #
  # @param [String] name The name of the property to be written.
  # @param [*Object] args The value or values to be assigned to the provided property name. If a single value is found
  #  a scalar will be written otherwise an array will be written.
  #
  # @return [Object,nil] The value written to the provided name.
  def set(name, *args)
    @config[name.to_sym] = args.size == 1 ? args.first : args
  end

  # Retrieves the value stored under the provided name.
  #
  # @param [String] name The name of the property to be read.
  #
  # @return [Object,nil] The value stored under the provided name or nil if no such value exists.
  def get(name)
    @config[name.to_sym]
  end

end
