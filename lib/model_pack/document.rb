module ModelPack
  module Document
    extend Concern

    included do
      extend ClassMethods
      include AttributeMethods
      prepend Constructor
      include Serialization
      include Serializers::JSON
    end
  end
end
