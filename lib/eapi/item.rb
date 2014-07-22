module Eapi
  module Item
    extend Common

    def self.extended(mod)
      def mod.included(klass)
        Eapi::Common.add_features klass
      end
    end

    def self.included(klass)
      Eapi::Common.add_features klass
    end

    def to_h
      render
    end

    def perform_render
      {}.tap do |hash|
        _properties.each do |prop|
          val        = converted_value_for(prop)
          hash[prop] = val unless to_be_ignored?(val, prop)
        end
      end
    end

    private
    def to_be_ignored?(value, property)
      Eapi::ValueIgnoreChecker.to_be_ignored? value, self.class.ignore_definition(property)
    end
  end
end