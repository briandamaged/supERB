
require 'erb'

module Superb

  module AttributeMagic

    def key_name_for(k)
      k.to_s.gsub(/^@*/, "").to_sym
    end
    module_function :key_name_for

    def field_name_for(k)
      ("@" + k.to_s.gsub(/^@*/, "")).to_sym
    end
    module_function :field_name_for

    def [](key)
      self.instance_variable_get(field_name_for(key))
    end

    def []=(key, value)
      self.instance_variable_set(field_name_for(key), value)
    end

    def method_missing(name, *args, &block)
      name_str = name.to_s

      if name_str.end_with? "="

        self.[]=(name[0...-1].to_sym, *args, &block)
      else
        self.[](name, *args, &block)
      end
    end

    def respond_to?(name)
      # TODO: Should only return true when string can be
      #       used as a method name.
      true
    end

    def merge!(hashable)
      hashable.to_hash.each do |k, v|
        self[k] = v
      end

      return self
    end

    def merge(hashable)
      self.dup.merge!(hashable)
    end

    def to_hash
      retval = {}
      instance_variables.each do |k|
        retval[key_name_for(k)] = self.instance_variable_get(k)
      end

      return retval
    end

  end


  # A Context instance is a container for instance
  # variables.  These variables can then be applied
  # to an ERB template.
  class Context
    include AttributeMagic

    def initialize(options = {})
      self.merge!(options)
    end

    def dup
      Superb::Context.new(self.to_hash)
    end

    def apply_to(template)
      template.result(binding)
    end

  end



  # Templates are bound to a specific ERB instance.
  # They maintain their own state, but they also allow
  # for individual values to be overridden when being
  # rendered.
  class Template
    include AttributeMagic

    attr_accessor :__erb

    def initialize(erb, options = {})
      @__erb = erb
      self.merge!(options)
    end

    def self.open(path, options = {})
      erb = Kernel.open(path){|fin| ERB.new(fin.read) }
      self.new(erb, options)
    end

    def dup
      Superb::Template.new(@__erb, self.to_hash)
    end

    def render(options = {})
      c = Superb::Context.new(self.to_hash)
      c.merge!(options)
      c.apply_to(@__erb)
    end
  end





end

