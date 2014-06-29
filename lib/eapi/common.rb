module Eapi
  module Common
    extend ActiveSupport::Concern
    included do |klass|
      klass.send :include, ActiveModel::Validations
      klass.send :include, Eapi::Methods::Properties::InstanceMethods
      Eapi::Children.append klass
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
          val        = Eapi::Common::Values.value_for_hash(get(prop))
          hash[prop] = val unless val.nil?
        end
      end
    end

    module ClassMethods
      include Eapi::Methods::Accessor
      include Eapi::Methods::Types::ClassMethods
      include Eapi::Methods::Properties::ClassMethods
    end

    module Values
      def self.value_for_hash(value)
        if value.nil?
          nil
        elsif is_list? value
          value_from_list value
        elsif is_hash?(value)
          value_from_hash value
        else
          value
        end
      end

      private
      def self.is_hash?(value)
        value.respond_to? :to_h
      end

      def self.is_list?(value)
        return false if value.kind_of?(Hash) || value.kind_of?(OpenStruct)

        value.respond_to? :to_a
      end

      def self.value_from_list(value)
        value.to_a.map { |e| value_for_hash e }.compact
      end

      def self.value_from_hash(value)
        {}.tap do |hash|
          value.to_h.each_pair do |k, v|
            val     = value_for_hash v
            hash[k] = val unless val.nil?
          end
          hash.deep_symbolize_keys!
        end
      end
    end
  end
end