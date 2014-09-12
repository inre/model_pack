module ModelPack
  module AttributeMethods
    extend Concern

    class_methods do
      def register_attribute(name)
        raise ArgumentError, "dublicate attribute with name `#{name}`" if attribute_names.include?(name)
        attribute_names.push name
        nil
      end

      def attribute_names
         class_variable_defined?(:@@attribute_names) ? class_variable_get(:@@attribute_names) : class_variable_set(:@@attribute_names, Array.new)
      end
    end

    def attributes
      self.class.attribute_names.inject({}) { |h, name| h[name] = send(name); h  }
    end

    def update_attributes(attributes)
      attributes.each do |name, attribute|
        key = "#{name}="
        send(key, attribute) if respond_to?(key)
      end
    end

    def update_attributes!(attributes)
      # check present first
      attributes.each do |name, attribute|
        raise ArgumentError, "undefined attribute `#{name}`" unless attribute_names.include?(method)
        key = "#{name}="
        send(key, attribute) if respond_to?(key)
      end
    end
  end
end
