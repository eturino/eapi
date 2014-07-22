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
          if current.respond_to? :add
            current.add value
          else
            current << value
          end

          send(fluent_setter, current)
        end
      end

      def define_multiple_clearer(field)
        init           = Eapi::Methods::Names.init field
        fluent_clearer = Eapi::Methods::Names.clearer field
        getter         = Eapi::Methods::Names.getter field

        define_method fluent_clearer do
          current = send(getter)
          if current.nil?
            # NOOP
          elsif current.respond_to?(:clear)
            current.clear
          elsif respond_to?(init)
            send(init)
          else
            raise Eapi::Errors::CannotClearFieldError, "#{self} can't clear #{field}: it does not respond to `clear` nor we have defined a `init_#{field}` method"
          end

          self
        end
      end

      def define_init(field, init_class)
        init         = Eapi::Methods::Names.init field
        instance_var = Eapi::Methods::Names.instance_var field

        define_method init do
          klass = Eapi::TypeChecker.constant_for_type init_class
          raise Eapi::Errors::InvalidInitClass, "init_class: #{init_class}" if klass.nil?
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
