module Eapi
  module Methods
    module Types
      def self.type_question_method(method)
        ms = method.to_s
        return false unless ms.end_with?('?')
        if ms.start_with?('is_a_')
          ms.sub('is_a_', '').sub('?', '')
        elsif ms.start_with?('is_an_')
          ms.sub('is_an_', '').sub('?', '')
        else
          nil
        end
      end

      def self.check_asking_type(method, obj)
        type = Types.type_question_method method
        if type
          obj.is?(type)
        else
          nil
        end
      end

      def self.to_type_sym(x)
        x.to_s.underscore.to_sym
      end

      module IsAnOtherTypeMethods
        def respond_to_missing?(method, include_all)
          if Types.type_question_method(method).present?
            true
          else
            super
          end
        end

        def method_missing(method, *args, &block)
          resp = Types.check_asking_type method, self
          if resp.nil?
            super
          else
            resp
          end
        end
      end

      module InstanceMethods
        def is?(type)
          return true if type.kind_of?(Module) && kind_of?(type)
          self.class.is?(type)
        end

        def self.included(klass)
          klass.send :include, IsAnOtherTypeMethods
        end
      end

      module ClassMethods
        def self.included(klass)
          klass.send :include, IsAnOtherTypeMethods
        end

        def is?(type)
          return true if Checker._is_type_module?(self, type)

          type_sym = Types.to_type_sym type
          return true if Checker._is_type_module_sym?(self, type_sym)

          return false unless @i_am_a.present?
          !!@i_am_a.include?(type_sym) # force it to be a bool
        end

        def is(*types)
          ts = types.map { |t| Types.to_type_sym t }

          @i_am_a ||= []
          @i_am_a.concat ts
        end
      end

      module Checker
        def self._is_type_module?(klass, mod_or_class)
          return false unless mod_or_class.kind_of?(Module)
          klass == mod_or_class || klass.ancestors.include?(mod_or_class)
        end

        def self._is_type_module_sym?(klass, type_sym)
          Types.to_type_sym(self) == type_sym || klass.ancestors.any? { |a| Types.to_type_sym(a) == type_sym }
        end
      end
    end
  end
end