module Eapi
  module Methods

    module Names
      def self.init(field)
        "init_#{field}"
      end

      def self.add(field)
        "add_#{field}"
      end

      def self.getter(field)
        "#{field}"
      end

      def self.setter(field)
        "#{field}="
      end

      def self.fluent_setter(field)
        "set_#{field}"
      end

      def self.instance_var(field)
        "@#{field}"
      end
    end
  end
end
