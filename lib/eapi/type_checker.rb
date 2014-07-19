module Eapi
  class TypeChecker

    def self.constant_for_type(type)
      if type.kind_of? Module
        type
      else
        begin
          type.to_s.constantize
        rescue NameError
          nil
        end
      end
    end

    attr_reader :given_type, :allow_raw

    def initialize(given_type, allow_raw = false)
      @given_type = given_type
      @allow_raw  = allow_raw
    end

    def is_valid_type?(value)
      value.nil? || valid_raw?(value) || is_same_type?(value) || poses_as_type?(value)
    end

    private
    def valid_raw?(value)
      return false unless allow_raw?

      value.kind_of?(Array) || value.kind_of?(Hash)
    end

    def is_same_type?(value)
      value.kind_of?(type_class) if type_class.present?
    end

    def poses_as_type?(value)
      value.respond_to?(:is?) && value.is?(type)
    end

    def type
      given_type
    end

    def type_class
      @type_class ||= load_type_class
    end

    def load_type_class
      Eapi::TypeChecker.constant_for_type given_type
    end

    def allow_raw?
      allow_raw
    end
  end
end