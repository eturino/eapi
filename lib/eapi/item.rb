module Eapi
  module Item
    extend Common

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