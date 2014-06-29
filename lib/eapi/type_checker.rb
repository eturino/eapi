module Eapi
  class TypeChecker < Struct.new(:given_type)
    def is_valid_type?(value)
      value.nil? || is_same_type?(value) || poses_as_type?(value)
    end

    private
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
  end
end