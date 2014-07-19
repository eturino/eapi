module Eapi
  module DefinitionRunners
    class Runner
      def self.validate_element_with(klass:, field:, validate_element_with:)
        klass.send :validates_each, field do |record, attr, value|
          if value.respond_to?(:each)
            value.each do |v|
              validate_element_with.call(record, attr, v)
            end
          end
        end
      end

      def self.validate_type(klass:, field:, type:)
        klass.send :validates_each, field do |record, attr, value|
          allow_raw = klass.property_allow_raw?(field)
          unless Eapi::TypeChecker.new(type, allow_raw).is_valid_type?(value)
            record.errors.add(attr, "must be a #{type}")
          end
        end
      end

      def self.validate_with(klass:, field:, validate_with:)
        klass.send :validates_each, field do |record, attr, value|
          validate_with.call(record, attr, value)
        end
      end

      def self.validate_element_type(klass:, field:, element_type:)
        klass.send :validates_each, field do |record, attr, value|
          allow_raw = klass.property_allow_raw?(field)
          if value.respond_to?(:each)
            value.each do |v|
              unless Eapi::TypeChecker.new(element_type, allow_raw).is_valid_type?(v)
                record.errors.add(attr, "element must be a #{element_type}")
              end
            end
          end
        end
      end

      def self.required(klass:, field:)
        klass.send :validates_presence_of, field
      end

      def self.unique(klass:, field:)
        klass.send :validates_each, field do |record, attr, value|
          if value.respond_to?(:group_by)
            grouped         = value.group_by { |i| i }
            repeated_groups = grouped.select { |k, v| v.size > 1 }
            unless repeated_groups.empty?
              repeated = Hash[repeated_groups.map { |k, v| [k, v.size] }]
              record.errors.add(attr, "elements must be unique (repeated elements: #{repeated})")
            end
          end
        end
      end

      def self.allow_raw(klass:, field:, allow_raw:)
        if allow_raw
          klass.send :property_allow_raw, field
        else
          klass.send :property_disallow_raw, field
        end
      end

      def self.init(klass:, field:, type:)
        klass.send :define_init, field, type
      end

      def self.multiple_accessor(klass:, field:)
        klass.send :define_multiple_accessor, field
      end

      def self.multiple_clearer(klass:, field:)
        klass.send :define_multiple_clearer, field
      end
    end
  end
end
