module Eapi
  module Common
    def self.add_features(klass)
      Eapi::Children.append klass
      klass.send :include, ActiveModel::Validations
      klass.send :include, Eapi::Methods::Properties::InstanceMethods
      klass.send :include, Eapi::Methods::Types::InstanceMethods

      klass.send :extend, ClassMethods
    end

    def self.extended(mod)
      def mod.included(klass)
        Eapi::Common.add_features klass
      end
    end

    def self.included(klass)
      Eapi::Common.add_features klass
    end

    def initialize(** properties)
      properties.each do |k, v|
        normal_setter = Eapi::Methods::Names.setter k
        #TODO: what to do with unrecognised properties
        send normal_setter, v if respond_to? normal_setter
      end
    end

    def to_h
      raise Eapi::Errors::InvalidElementError, "errors: #{errors.full_messages}, self: #{self.inspect}" unless valid?

      create_hash
    end

    def create_hash
      {}.tap do |hash|
        self.class.properties.each do |prop|
          val        = Eapi::ValueConverter.convert_value(get(prop))
          hash[prop] = val unless val.nil?
        end
      end
    end

    module ClassMethods
      include Eapi::Methods::Accessor
      include Eapi::Methods::Types::ClassMethods
      include Eapi::Methods::Properties::ClassMethods
    end

  end
end