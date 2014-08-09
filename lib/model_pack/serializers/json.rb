require 'json'

module ModelPack
  module Serializers::JSON
    def to_json
      as_json.to_json
    end

    def as_json(options=nil)
      serializable_hash(options)
    end
  end
end
