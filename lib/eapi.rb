require 'active_support/all'
require 'active_model'

require 'eapi/version'
require 'eapi/errors'
require 'eapi/children'
require 'eapi/multiple'
require 'eapi/methods'
require 'eapi/value_converter'
require 'eapi/common'


module Eapi
  def self.method_missing(method, *args, &block)
    klass = Eapi::Children.get(method)
    if klass
      klass.new *args, &block
    else
      super
    end
  end
end