module Eapi
  module Common
    extend ActiveSupport::Concern
    included do
      include ActiveModel::Validations
      include Eapi::Methods::Properties::InstanceMethods
    end

    def initialize(** properties)
      properties.each do |k, v|
        normal_setter = "#{k}="
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
          stored     = get(prop)
          val        = (stored.present? && stored.respond_to?(:to_h)) ? stored.to_h : stored
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