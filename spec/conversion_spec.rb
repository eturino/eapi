require 'spec_helper'

RSpec.describe Eapi do

  describe 'convert_with' do

    context 'Item' do

      class ExampleItemConvertWith
        include Eapi::Item

        property :something, convert_with: :to_s
        property :other, convert_with: ->(val) { "This is #{val}" }
        property :third, convert_with: ->(val, obj) do
          s = obj.something
          c = obj.send :converted_value_for, :something
          "I am #{val} with some #{s.inspect} as #{c.inspect}"
        end
      end

      subject { ExampleItemConvertWith.new something: :x, other: 1, third: 'the third' }

      context 'message (symbol or string)' do
        it 'in the rendered hash, the value is converted by sending the message to the value' do
          expect(subject.render[:something]).to eq 'x'
        end
      end

      context 'callable object with 1 argument' do
        it 'in the rendered hash, the value is converted by sending `call` to the callable object and passing the value as single argument' do
          expect(subject.render[:other]).to eq 'This is 1'
        end
      end

      context 'callable object with 2 arguments' do
        it 'in the rendered hash, the value is converted by sending `call` to the callable object and passing the value as first argument and the context object (item) as second argument' do
          expect(subject.render[:third]).to eq "I am the third with some :x as \"x\""
        end
      end
    end

    context 'List' do
      class ExampleListConvertWith
        include Eapi::List

        elements convert_with: :to_s
      end

      subject { ExampleListConvertWith.new.add(1).add(2) }

      it 'with a given option for `context_with`, it will use to convert all elements of the list' do
        expect(subject.render).to eq ['1', '2']
      end
    end
  end

  describe 'convert_before_validation option' do

    context 'Item' do
      class ExampleItemConvertBeforeValidation
        include Eapi::Item

        property :something, prepare_with: :to_i
        property :normal

        validates :something, inclusion: {in: [1, 2, 3]}
        validates :normal, inclusion: {in: [1, 2, 3]}
      end

      context 'enabled' do
        subject { ExampleItemConvertBeforeValidation.new something: '1', normal: 2 }
        it 'the conversion happens before validation' do
          expect(subject).to be_valid
        end
      end

      context 'disabled' do
        subject { ExampleItemConvertBeforeValidation.new something: 1, normal: '2' }
        it 'the conversion happens on rendering, after validation' do
          expect(subject).not_to be_valid
        end
      end
    end

    context 'List' do
      class ExampleListConvertBeforeValidationEnabled
        include Eapi::List

        elements prepare_with: :to_i, validate_with: ->(record, attr, value) do
          record.errors.add(attr, 'must pass my custom validation') unless value.kind_of?(Fixnum)
        end
      end

      class ExampleListConvertBeforeValidationDisabled
        include Eapi::List

        elements convert_with: :to_i, validate_with: ->(record, attr, value) do
          record.errors.add(attr, 'must pass my custom validation') unless value.kind_of?(Fixnum)
        end
      end

      context 'enabled' do
        subject { ExampleListConvertBeforeValidationEnabled.new.add('1') }
        it 'the conversion happens before validation' do
          expect(subject).to be_valid
        end
      end

      context 'disabled' do
        subject { ExampleListConvertBeforeValidationDisabled.new.add('1') }
        it 'the conversion happens on rendering, after validation' do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end