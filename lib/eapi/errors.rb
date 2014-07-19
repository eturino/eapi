module Eapi
  module Errors
    class InvalidElementError < StandardError
    end

    class InvalidInitClass < StandardError
    end

    class CannotClearFieldError < StandardError
    end
  end
end