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

    def render
      validate!
      create_hash
    end

    alias_method :to_h, :render

    def create_hash
      {}.tap do |hash|
        _properties.each do |prop|
          val        = converted_value_for(prop)
          hash[prop] = val unless val.nil?
        end
      end
    end
  end
end