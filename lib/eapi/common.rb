module Eapi
  module Common
    extend ActiveSupport::Concern
    included do |klass|
      klass.send :include, ActiveModel::Validations
      klass.send :include, Eapi::Methods::Properties::InstanceMethods
      klass.send :include, Eapi::Methods::Types::InstanceMethods
      Eapi::Children.append klass
    end

    def initialize(** properties)
      properties.each do |k, v|
        normal_setter = Eapi::Methods::Names.setter k
        #TODO: what to do with unrecognised properties
        send normal_setter, v if respond_to? normal_setter
      end
    end

    def method_missing(method, *args)
      catch(:response) do
        Eapi::Methods::Types.check_asking_type method, self

        # if nothing catch -> continue super
        super
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