module Eapi
  module Methods

    module Accessor
      class InvalidInitClass < StandardError
      end

      def define_multiple_accessor(field)
        init          = Eapi::Methods::Names.init field
        fluent_adder  = Eapi::Methods::Names.add field
        fluent_setter = Eapi::Methods::Names.fluent_setter field
        getter        = Eapi::Methods::Names.getter field

        define_method fluent_adder do |value|
          current = send(getter) || send(init)
          current << value
          send(fluent_setter, current)
        end
      end

      def define_init(field, init_class)
        init         = Eapi::Methods::Names.init field
        instance_var = Eapi::Methods::Names.instance_var field

        define_method init do
          klass = Eapi::TypeChecker.constant_for_type init_class
          raise InvalidInitClass, "init_class: #{init_class}" if klass.nil?
          value = klass.new
          instance_variable_set instance_var, value
        end
      end

      def define_accessors(field)
        fluent_accessor field
      end
    end
  end
end
