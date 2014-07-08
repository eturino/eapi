module Eapi
  module Methods

    module Properties
      module InstanceMethods

        def _properties
          self.class.properties
        end

        def converted_value_for(prop)
          convert_value get(prop)
        end

        def convert_value(value)
          Eapi::ValueConverter.convert_value(value)
        end

        def get(field)
          getter = Eapi::Methods::Names.getter field
          send(getter)
        end

        def set(field, value)
          setter = Eapi::Methods::Names.fluent_setter field
          send(setter, value)
        end
      end

      module ClassMethods
        def property(field, definition = {})
          fs = field.to_sym
          define_accessors fs
          run_definition fs, definition
          store_definition fs, definition
        end

        def properties
          @_definitions.keys
        end

        def definition_for(field)
          @_definitions ||= {}
          @_definitions.fetch(field.to_sym, {}).dup
        end

        def store_definition(field, definition)
          @_definitions        ||= {}
          @_definitions[field] = definition
        end

        def run_definition(field, definition)
          Eapi::DefinitionRunner.new(self, field, definition).run
        end

        private :run_definition
        private :store_definition
      end
    end

  end
end