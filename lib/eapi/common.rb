module Eapi
  module Common
    def self.add_features(klass)
      Eapi::Children.append klass
      klass.send :include, ActiveModel::Validations
      klass.send :include, Eapi::Common::Basic
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

    module Basic
      def initialize(** properties)
        properties.each do |k, v|
          normal_setter = Eapi::Methods::Names.setter k
          #TODO: what to do with unrecognised properties
          send normal_setter, v if respond_to? normal_setter
        end
      end

      def to_h
        validate!
        create_hash
      end

      def validate!
        raise Eapi::Errors::InvalidElementError, "errors: #{errors.full_messages}, self: #{self.inspect}" unless valid?
      end

      def create_hash
        {}.tap do |hash|
          _properties.each do |prop|
            val        = converted_value_for(prop)
            hash[prop] = val unless val.nil?
          end
        end
      end
    end

    module ClassMethods
      include FluentAccessors
      include Eapi::Methods::Accessor
      include Eapi::Methods::Types::ClassMethods
      include Eapi::Methods::Properties::ClassMethods
    end

  end
end