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

    private
    def perform_render
      {}.tap do |hash|
        _properties.each do |prop|
          set_value_in_final_hash(hash, prop)
        end
      end
    end
  end
end