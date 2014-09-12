module ModelPack
  module Constructor
    def initialize(*a)
      attributes = a.pop
      update_attributes(attributes) if attributes
      super(*a)
    end
  end
end
