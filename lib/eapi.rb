require 'active_support/all'
require 'active_model'

require 'eapi/version'
require 'eapi/errors'
require 'eapi/multiple'
require 'eapi/methods'
require 'eapi/common'


module Eapi
  def self.method_missing(method, *args, &block)
    klass = const_get("Eapi::#{method}")
    klass.new *args, &block
  end
end