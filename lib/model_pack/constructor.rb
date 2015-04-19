module ModelPack
  module Constructor
    def initialize(*a)
      attributes = a.pop
      update_attributes(attributes) if attributes
      update_attributes(a.pop) if a.last.is_a?(Hash)
      super(*a)
    end
  end
end
