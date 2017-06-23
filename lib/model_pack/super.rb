module ModelPack
  class Super
    extend ClassMethods
    include AttributeMethods
    include Serialization
    include Serializers::JSON

    def initialize(args)
      if args.is_a? Hash
        update_attributes(args)
      else
        deserialize(args)
      end
    end

    protected

    def deserialize(args)
      if deserialize?(args)
        update_attributes(args.first)
        true
      else
        false
      end
    end

    def deserialize?(args)
      args.size == 1 && args.first.is_a?(Hash)
    end
  end
end
