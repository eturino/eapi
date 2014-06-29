module Eapi
  class DefinitionRunner < Struct.new(:klass, :field, :definition)
    def run
      run_multiple_accessor
      run_init
      run_validations
    end

    private
    def run_validations
      run_required
      run_validate_type
      run_validate_with
      run_validate_type_element
      run_validate_element_with
    end

    def run_validate_type
      if type
        klass.send :validates_each, field do |record, attr, value|
          unless Eapi::TypeChecker.new(type).is_valid_type?(value)
            record.errors.add(attr, "must be a #{type}")
          end
        end
      end
    end

    def run_validate_element_with
      if multiple && validate_element_with
        validates_each field do |record, attr, value|
          if value.respond_to?(:each)
            value.each do |v|
              validate_element_with.call(record, attr, v)
            end
          end
        end
      end
    end

    def run_validate_type_element
      if multiple && type_element
        validates_each field do |record, attr, value|
          if value.respond_to?(:each)
            value.each do |v|
              record.errors.add(attr, "element must be a #{type}") unless v.kind_of?(type)
            end
          end
        end
      end
    end

    def run_validate_with
      if validate_with
        klass.send :validates_each, field do |record, attr, value|
          validate_with.call(record, attr, value)
        end
      end
    end

    def run_required
      if required
        klass.send :validates_presence_of, field
      end
    end

    def run_init
      if type || multiple
        klass.send :define_init, field, type || Array
      end
    end

    def run_multiple_accessor
      if multiple
        klass.send :define_multiple_accessor, field
      end
    end

    def type_multiple?(type)
      return false if type.nil?
      return true if type == Array || type == Set

      type.respond_to?(:is_multiple?) && type.is_multiple?
    end

    def validate_element_with
      definition.fetch(:validate_element_with, nil)
    end

    def multiple
      definition.fetch(:multiple, false) || type_multiple?(type)
    end

    def required
      definition.fetch(:required, false)
    end

    def validate_with
      definition.fetch(:validate_with, nil)
    end

    def type_element
      definition.fetch(:type_element, nil)
    end

    def type
      definition.fetch(:type, nil)
    end
  end
end