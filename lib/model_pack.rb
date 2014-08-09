require "model_pack/version"

module ModelPack
  autoload :AttributeMethods, 'model_pack/attribute_methods'
  autoload :ClassMethods,     'model_pack/class_methods'
  autoload :Concern,          'model_pack/concern'
  autoload :Constructor,      'model_pack/constructor'
  autoload :Document,         'model_pack/document'
  autoload :Serialization,    'model_pack/serialization'

  module Serializers
    autoload :JSON,           'model_pack/serializers/json'
  end
end
