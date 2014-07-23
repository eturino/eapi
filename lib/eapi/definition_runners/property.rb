module Eapi
  module DefinitionRunners

    class Property < Struct.new(:klass, :field, :definition)
      def run
        run_multiple_accessor
        run_multiple_clearer
        run_init
        run_validations
        run_allow_raw
      end

      private
      def run_validations
        run_required
        run_validate_type
        run_validate_with
        run_validate_element_type
        run_validate_element_with
      end

      def run_required
        if required?
          Runner.required klass: klass, field: field
        end
      end

      def run_validate_element_with
        if multiple? && validate_element_with
          Runner.validate_element_with klass: klass, field: field, validate_element_with: validate_element_with
        end
      end

      def run_validate_element_type
        if multiple? && element_type
          Runner.validate_element_type(klass: klass, field: field, element_type: element_type)
        end
      end

      def run_validate_type
        if type
          Runner.validate_type(klass: klass, field: field, type: type)
        end
      end

      def run_validate_with
        if validate_with
          Runner.validate_with(klass: klass, field: field, validate_with: validate_with)
        end
      end

      def run_allow_raw
        Runner.allow_raw(klass: klass, field: field, allow_raw: allow_raw?)
      end

      def run_init
        if init_class
          Runner.init(klass: klass, field: field, type: init_class)
        elsif multiple? && (type.blank? || type.to_s == 'Array')
          Runner.init(klass: klass, field: field, type: Array)
        end
      end

      def run_multiple_accessor
        if multiple?
          Runner.multiple_accessor(klass: klass, field: field)
        end
      end

      def run_multiple_clearer
        if multiple?
          Runner.multiple_clearer(klass: klass, field: field)
        end
      end

      def type_multiple?(type)
        type_class = Eapi::TypeChecker.constant_for_type type

        return false if type_class.nil?
        return true if type_class == Array || type_class == Set

        type_class.respond_to?(:is_multiple?) && type_class.is_multiple?
      end

      def validate_element_with
        definition.fetch(:validate_element_with, nil)
      end

      def multiple?
        definition.fetch(:multiple, false) || type_multiple?(type) || type_multiple?(init_class)
      end

      def required?
        definition.fetch(:required, false)
      end

      def allow_raw?
        definition.fetch(:allow_raw, false)
      end

      def validate_with
        definition.fetch(:validate_with, nil)
      end

      def element_type
        definition.fetch(:element_type, nil)
      end

      def type
        definition.fetch(:type, nil)
      end

      def init_class
        definition.fetch(:init_class, nil)
      end

    end
  end
end
