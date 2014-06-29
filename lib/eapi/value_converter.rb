module Eapi
  module ValueConverter
    def self.convert_value(value)
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
      value.to_a.map { |e| convert_value e }.compact
    end

    def self.value_from_hash(value)
      {}.tap do |hash|
        value.to_h.each_pair do |k, v|
          val     = convert_value v
          hash[k] = val unless val.nil?
        end
        hash.deep_symbolize_keys!
      end
    end
  end
end