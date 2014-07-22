require 'fluent_accessors'
require 'active_support/all'
require 'active_model'

require 'eapi/version'
require 'eapi/errors'
require 'eapi/children'
require 'eapi/multiple_value'
require 'eapi/definition_runners'
require 'eapi/type_checker'
require 'eapi/value_ignore_checker'
require 'eapi/methods'
require 'eapi/value_converter'
require 'eapi/common'
require 'eapi/item'
require 'eapi/list'


module Eapi
  def self.add_method_missing(klass)
    def klass.method_missing(method, *args, &block)
      child_klass = Eapi::Children.get(method, self)
      if child_klass
        child_klass.new *args, &block
      else
        super
      end
    end
  end

  add_method_missing self

  def self.extended(mod)
    mod.class_eval <<-CODE
      Common = Eapi::Common
      Item = Eapi::Item
      List = Eapi::List
      Children = Eapi::Children
    CODE
    Eapi.add_method_missing mod
  end
end