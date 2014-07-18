module Eapi
  class TypeChecker

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
      value.kind_of?(type)
    end

    def poses_as_type?(value)
      value.respond_to?(:is?) && value.is?(type)
    end

    def type
      if given_type.kind_of? Module
        given_type
      else
        given_type.to_s.constantize
      end
    end

    def allow_raw?
      allow_raw
    end
  end
end