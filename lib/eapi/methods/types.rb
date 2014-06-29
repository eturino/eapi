module Eapi
  module Methods
    module Types
      def self.type_question_method(method)
        ms = method.to_s
        if ms.start_with?('is_a_') && ms.end_with?('?')
          ms.sub('is_a_', '').sub('?', '')
        else
          nil
        end
      end

      def self.check_asking_type(method, obj)
        type = Types.type_question_method method
        if type
          throw :response, obj.class.is?(type)
        end
      end

      def self.to_type_sym(x)
        x.to_s.to_sym
      end

      module InstanceMethods
        def is?(type)
          self.class.is?(type)
        end
      end


      module ClassMethods
        def is?(type)
          self == type ||
            Types.to_type_sym(self) == Types.to_type_sym(type) ||
            @i_am_a && @i_am_a.include?(type.to_s.to_sym)
        end

        def is(*types)
          ts = types.map { |t| Types.to_type_sym t }

          @i_am_a ||= []
          @i_am_a.concat ts
        end
      end

    end
  end
end