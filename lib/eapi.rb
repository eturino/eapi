require 'active_support/all'
require 'active_model'

require 'eapi/version'
require 'eapi/errors'
require 'eapi/children'
require 'eapi/multiple'
require 'eapi/definition_runner'
require 'eapi/type_checker'
require 'eapi/methods'
require 'eapi/value_converter'
require 'eapi/common'


module Eapi
  def self.add_method_missing(klass)
    def klass.method_missing(method, *args, &block)
      klass = Eapi::Children.get(method)
      if klass
        klass.new *args, &block
      else
        super
      end
    end
  end

  add_method_missing self

  def self.extended(mod)
    mod.class_eval <<-CODE
      Common = Eapi::Common
      Children = Eapi::Children
    CODE
    Eapi.add_method_missing mod
  end
end