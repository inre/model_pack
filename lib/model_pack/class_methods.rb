module ModelPack
  module ClassMethods

    def attribute(name, writer: lambda { |v| v }, default: nil, as: nil, serialize: nil)
      attribute_reader(name, default: default, as: as, serialize: serialize)
      attribute_writer(name, writer: writer)
      register_attribute(name)
    end

    def attribute_writer(name, writer: lambda { |v| v })
      define_method "#{name}=" do |value|
        instance_variable_set("@#{name}", instance_exec(value, &writer))
      end
    end

    def attribute_reader(name, default: nil, as: nil, serialize: nil)
      default_dup = default.dup rescue default
      default_value = default_dup || (as && as.new)

      define_method name do
        instance_variable_defined?("@#{name}") ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", default_value)
      end

      define_method "#{name}_hash" do
        instance_exec(send(name), &serialize)
      end if serialize
    end

    def object(name, class_name: nil, default: nil, serialize: nil)
      attribute(name,
        default: default,
        serialize: serialize,
        writer: lambda { |v| v.is_a?(Hash) && class_name ? class_name.new(v) : v })
    end

    def array(name, default: nil, serialize: nil, writer: nil, class_name: nil)
      attribute(name,
          default: default,
          serialize: serialize,
          as: Array,
          writer: writer || lambda { |array| array.collect { |v| v.is_a?(Hash) && class_name ? class_name.new(v) : v } })
    end

    def dictionary(name, class_name: nil, default: nil, serialize: nil, writer: nil)
      attribute(name,
          default: default,
          serialize: serialize,
          writer: writer || lambda { |dictionary| Hash[dictionary.map { |k,v| [k, v.is_a?(Hash) && class_name ? class_name.new(v) : v]}] },
          as: Hash)
    end
  end
end
