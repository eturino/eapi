module Eapi
  module DefinitionRunners


    class List < Struct.new(:klass, :definition)
      def run
        run_validations
      end

      private
      def run_validations
        run_required
        run_validate_element_type
        run_validate_element_with
        run_validate_uniqueness
      end

      def run_validate_uniqueness
        if unique?
          Runner.unique klass: klass, field: :_list
        end
      end

      def run_validate_element_with
        if validate_element_with
          Runner.validate_element_with klass: klass, field: :_list, validate_element_with: validate_element_with
        end
      end

      def run_validate_element_type
        if element_type
          Runner.validate_element_type(klass: klass, field: :_list, element_type: element_type)
        end
      end

      def run_required
        if required?
          Runner.required(klass: klass, field: :_list)
        end
      end

      def required?
        definition.fetch(:required, false)
      end

      def unique?
        definition.fetch(:unique, false)
      end

      def validate_element_with
        definition.fetch(:validate_element_with, nil) || definition.fetch(:validate_with, nil)
      end

      def element_type
        definition.fetch(:element_type, nil) || definition.fetch(:type, nil)
      end
    end

  end
end
