module Eapi
  module Methods

    module Properties
      module InstanceMethods

        def _properties
          self.class.properties
        end

        def get(field)
          getter = Eapi::Methods::Names.getter field
          send(getter)
        end

        def set(field, value)
          setter = Eapi::Methods::Names.fluent_setter field
          send(setter, value)
        end

        def converted_value_for(prop)
          convert_value get(prop), self.class.defined_convert_with_for(prop)
        end

        def convert_value(value, convert_with = nil)
          Eapi::ValueConverter.convert_value(value, self, convert_with)
        end

        def converted_or_default_value_for(property)
          yield_final_value_for(property) { |val| return val }
        end

        # will yield the converted value if it is not to be ignored,
        # will yield the default value if it is set and the converted value is to be ignored
        # will not yield anything otherwise
        def yield_final_value_for(property)
          val      = converted_value_for(property)
          accepted = !to_be_ignored?(val, property)

          if accepted
            yield val
          elsif self.class.default_value_for?(property)
            yield self.class.default_value_for(property)
          end
        end

        def to_be_ignored?(value, property)
          Eapi::ValueIgnoreChecker.to_be_ignored? value, self.class.ignore_definition(property)
        end

        private
        def set_value_in_final_hash(hash, property)
          yield_final_value_for(property) do |val|
            hash[property] = val
          end
        end
      end

      module ClassMethods
        def property_allow_raw(field)
          _property_allow_raw[field.to_sym] = true
        end

        def property_disallow_raw(field)
          _property_allow_raw[field.to_sym] = false
        end

        def property_allow_raw?(field)
          _property_allow_raw.fetch(field.to_sym, false)
        end

        def property(field, definition = {})
          fs = field.to_sym
          define_accessors fs
          run_property_definition fs, definition
          store_property_definition fs, definition
        end

        def properties
          _property_definitions.keys
        end

        def definition_for(field)
          _property_definitions.fetch(field.to_sym, {}).dup
        end

        def store_property_definition(field, definition)
          _property_definitions[field] = definition.tap { |x| x.freeze }
        end

        def run_property_definition(property_field, definition)
          Eapi::DefinitionRunners::Property.new(self, property_field, definition).run
        end

        def _property_allow_raw
          @_property_allow_raw ||= {}
        end

        def _property_definitions
          @_property_definitions ||= {}
        end

        def ignore_definition(field)
          definition_for(field).fetch(:ignore, :nil?)
        end

        def default_value_for?(property)
          definition_for(property).key? :default
        end

        def default_value_for(property)
          definition_for(property).fetch(:default, nil)
        end

        def defined_convert_with_for(property)
          definition_for(property).fetch(:convert_with, nil)
        end

        def convert_before_validation?(property)
          definition_for(property).fetch(:convert_before_validation, false)
        end

        private :_property_allow_raw
        private :_property_definitions
        private :run_property_definition
        private :store_property_definition
      end

      module ListInstanceMethods
        def set_value_in_final_array(array, value)
          yield_final_value_for_elements(value) do |val|
            array << val
          end
        end

        def yield_final_value_for_elements(value)
          yield convert_value_for_element(value) unless to_be_ignored?(value)
        end

        def to_be_ignored?(value)
          Eapi::ValueIgnoreChecker.to_be_ignored? value, self.class.elements_ignore_definition
        end

        def convert_value_for_element(value)
          convert_value(value, self.class.elements_defined_convert_with_for)
        end
      end

      module ListCLassMethods
        def elements_allow_raw
          property_allow_raw(:_list)
        end

        def elements_disallow_raw
          property_disallow_raw(:_list)
        end

        def elements_allow_raw?
          property_allow_raw?(:_list)
        end

        def elements_ignore_definition
          definition_for_elements.fetch(:ignore, :nil?)
        end

        def elements_convert_before_validation?
          definition_for_elements.fetch(:convert_before_validation, false)
        end

        def elements(definition)
          run_list_definition definition
          store_list_definition definition
        end

        def elements_defined_convert_with_for
          definition_for_elements.fetch(:convert_with, nil)
        end

        def definition_for_elements
          @_list_definition ||= {}
        end

        def store_list_definition(definition)
          @_list_definition = definition.tap { |x| x.freeze }
        end

        def run_list_definition(definition)
          Eapi::DefinitionRunners::List.new(self, definition).run
        end

        private :run_list_definition
        private :store_list_definition
      end
    end

  end
end