module Eapi
  module Methods

    module Accessor
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

      def define_init(field, type_class)
        init         = Eapi::Methods::Names.init field
        instance_var = Eapi::Methods::Names.instance_var field

        define_method init do
          value = type_class.new
          instance_variable_set instance_var, value
        end
      end

      def define_accessors(field)
        normal_setter = Eapi::Methods::Names.setter field
        fluent_setter = Eapi::Methods::Names.fluent_setter field
        getter        = Eapi::Methods::Names.getter field
        instance_var  = Eapi::Methods::Names.instance_var field

        define_method normal_setter do |value|
          instance_variable_set instance_var, value
        end

        # fluent setter that calls the normal setter and returns self
        define_method fluent_setter do |value|
          send normal_setter, value
          self
        end

        # special getter => if no arguments it is a getter, if arguments it calls the fluent setter
        define_method getter do |*args|
          if args.empty?
            instance_variable_get instance_var
          else
            send fluent_setter, *args
          end
        end
      end
    end
  end
end
