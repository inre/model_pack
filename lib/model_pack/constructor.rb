module ModelPack
  module Constructor
    def initialize(*a)
      update_attributes(a.pop) if a.last.is_a?(Hash)
      super(*a)
    end
  end
end
