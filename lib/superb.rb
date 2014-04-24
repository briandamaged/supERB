
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

    def merge!(hashable)
      hashable.to_hash.each do |k, v|
        self[k] = v
      end
    end

    def to_hash
      retval = {}
      instance_variables.each do |k|
        retval[key_name_for(k)] = self.instance_variable_get(k)
      end

      return retval
    end

  end


  class Context
    include AttributeMagic

    def initialize(options = {})
      self.merge!(options)
    end


    def render(template)
      template.result(binding)
    end

  end


end

