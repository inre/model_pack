module ModelPack
  class Super
    extend ClassMethods
    include AttributeMethods
    include Serialization
    include Serializers::JSON

    def initialize(args = {})
      update_attributes(args) if args.is_a? Hash
    end
  end
end
