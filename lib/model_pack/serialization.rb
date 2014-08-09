module ModelPack
  module Serialization

    def serializable_attribute_names(attributes, options)
      names = attributes.keys.sort
      case options
        when Hash
          names &= Array.wrap(options.keys).map(&:to_s)
        when true
          # do nothing
        when false
          names = {}
        when nil
          names = {}
      else
        names &= Array.wrap(options).map(&:to_s)
      end

      names
    end

    def serializable_hash(options = nil, global = nil)
      serializable_value =
        ->(value, *a) { value.respond_to?(:serializable_hash) ? value.serializable_hash(*a[0...value.method(:serializable_hash).arity]) : value }
      enumerable_value = ->(value, *a) {
        value.is_a?(Hash) ? value.inject({}) { |h, e| h[e.first] = serializable_value[e.last, *a]; h } :
        (value.is_a?(Enumerable) ? value.map{ |v| serializable_value[v, *a] } : serializable_value[value, *a])
      }

      hash = {}
      options = Hash[*options.map{|v| [v, true]}.flatten(2)] if options.is_a?(Array)
      self.class.attribute_names.each do |n|
        opts = options ? options[n] : nil
        empty = options.nil? || options.empty?
        n_hash = "#{n}_hash"
        if (opts || empty) && respond_to?(n_hash)
          value = send(n_hash, *(method(n_hash).arity.zero? ? [] : [opts, global]))
          hash[n] = value if value
          next
        end

        value =  send(n)
        data = case opts
        when Symbol
          value.send(opts)
        when true
          enumerable_value[value, nil, global]
        when false
          nil
        when nil
          # auto detect value type if options nil too
          empty ? enumerable_value[value, nil, global] : nil
        when Hash
          enumerable_value[value, opts, global]
        end
        hash[n] = data if data
      end
      hash
    end

    def copy
      self.class.new(self.serializable_hash)
    end

    #<<<
  end
end
