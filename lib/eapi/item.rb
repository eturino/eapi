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
          set_value_in_final_hash(hash, prop)
        end
      end
    end

    private
    def to_be_ignored?(value, property)
      Eapi::ValueIgnoreChecker.to_be_ignored? value, self.class.ignore_definition(property)
    end

    def set_value_in_final_hash(hash, prop)
      val     = converted_value_for(prop)
      ignored = to_be_ignored?(val, prop)

      if ignored && self.class.default_value_for?(prop)
        hash[prop] = self.class.default_value_for(prop)
      elsif ignored
        # NOOP
      else
        hash[prop] = val
      end
    end
  end
end