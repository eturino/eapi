module Eapi
  class ValueIgnoreChecker
    def self.to_be_ignored?(value, ignore_definition = nil)
      if ignore_definition.nil?
        check_by_default value
      elsif !ignore_definition
        false
      elsif ignore_definition.respond_to? :call
        check_by_callable value, ignore_definition
      else
        check_by_message value, ignore_definition
      end
    end

    private
    def self.check_by_default(value)
      value.nil?
    end

    def self.check_by_message(value, ignore_definition)
      value.send ignore_definition
    end

    def self.check_by_callable(value, ignore_definition)
      ignore_definition.call value
    end
  end
end
