module Eapi
  module ValueConverter
    def self.convert_value(value, context, convert_with = nil)

      if convert_with.present?
        value_using_convert_with(value, context, convert_with)
      elsif value.nil?
        nil
      elsif can_render? value
        value_from_render value
      elsif is_list? value
        value_from_list value, context
      elsif is_hash?(value)
        value_from_hash value, context
      else
        value
      end
    end

    private
    def self.value_using_convert_with(value, context, convert_with)
      if convert_with.respond_to? :call
        value_using_callable value, context, convert_with
      else
        value_using_message value, convert_with
      end
    end

    def self.value_using_callable(value, context, callable)
      a = callable.try(:arity) || callable.method(:call).arity
      case a
        when 0
          callable.call
        when 1
          callable.call value
        else
          callable.call value, context
      end
    end

    def self.value_using_message(value, message)
      value.send message
    end

    def self.can_render?(value)
      value.respond_to? :render
    end

    def self.is_hash?(value)
      value.respond_to? :to_h
    end

    def self.is_list?(value)
      return false if value.kind_of?(Hash) || value.kind_of?(OpenStruct)

      value.respond_to? :to_a
    end

    def self.value_from_render(value)
      value.render
    end

    def self.value_from_list(value, context)
      value.to_a.map { |e| convert_value e, context }.compact
    end

    def self.value_from_hash(value, context)
      {}.tap do |hash|
        value.to_h.each_pair do |k, v|
          val     = convert_value v, context
          hash[k] = val unless val.nil?
        end
        hash.deep_symbolize_keys!
      end
    end
  end
end