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

      def self.validate_element_type(klass:, field:, element_type:)
        klass.send :validates_each, field do |record, attr, value|
          if value.respond_to?(:each)
            value.each do |v|
              unless Eapi::TypeChecker.new(element_type).is_valid_type?(v)
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
    end
  end
end
