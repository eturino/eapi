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


      module ClassMethods
        def is?(type)
          @i_am_a && @i_am_a.include?(type.to_sym)
        end

        def is(*types)
          @i_am_a ||= []
          @i_am_a.concat(types.map(&:to_sym))
        end
      end

    end
  end
end