module Eapi
  module MultipleValue
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def is_multiple?
        true
      end
    end
  end
end