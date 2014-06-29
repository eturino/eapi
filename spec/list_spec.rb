require 'spec_helper'

RSpec.describe Eapi do

  context 'list' do
    class MyTestClassValMult
      include Eapi::Common

      property :something, multiple: true
    end

    it '#add_something' do
      eapi = MyTestClassValMult.new something: [1, 2]
      res  = eapi.add_something 3
      expect(res).to be eapi
      expect(eapi.something).to eq [1, 2, 3]
    end

    it '#init_something called on first add if element is nil' do
      eapi = MyTestClassValMult.new
      res  = eapi.add_something :a
      expect(res).to be eapi
      expect(eapi.something.to_a).to eq [:a]
    end

    class MyTestClassValMultImpl
      include Eapi::Common

      property :something, type: Set
    end

    class MyMultiple
      def self.is_multiple?
        true
      end

      def <<(x)
        @elements ||= []
        @elements << x
      end

      def to_a
        @elements.to_a
      end
    end

    class MyTestClassValMultImpl2
      include Eapi::Common

      property :something, type: MyMultiple
    end

    class MyMultipleEapi
      include Eapi::Multiple

      def <<(x)
        @elements ||= []
        @elements << x
      end

      def to_a
        @elements.to_a
      end
    end

    class MyTestClassValMultImpl3
      include Eapi::Common

      property :something, type: MyMultipleEapi
    end

    it 'if type is Array or Set, or responds true to is_multiple?, it is multiple implicitly + uses that class to initialize the property when adding' do
      [
        [MyTestClassValMult, Array],
        [MyTestClassValMultImpl, Set],
        [MyTestClassValMultImpl2, MyMultiple],
        [MyTestClassValMultImpl3, MyMultipleEapi],
      ].each do |(eapi_class, type_class)|
        eapi = eapi_class.new
        res  = eapi.add_something :a
        expect(res).to be eapi
        expect(eapi.something.to_a).to eq [:a]
        expect(eapi.something).to be_a_kind_of type_class
      end
    end

    describe 'element validation' do
      class MyTestClassValElements
        include Eapi::Common
        property :something, multiple: true, element_type: Hash
        property :other, multiple: true, validate_element_with: ->(record, attr, value) do
          record.errors.add(attr, "element must pass my custom validation") unless value == :valid_val
        end
      end

      describe 'using `type_element` property in definition' do
        it 'will validate the type of all the elements in the list' do
          eapi = MyTestClassValElements.new
          eapi.add_something 1
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq ["Something element must be a Hash"]
          expect(eapi.errors.messages).to eq({something: ["element must be a Hash"]})

          eapi.something [{a: :b}]
          expect(eapi).to be_valid
        end
      end

      describe 'using `validate_element_with` property in definition' do
        it 'will run that custom validation for all the elements in the list' do
          eapi = MyTestClassValElements.new
          eapi.add_other 1
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq ["Other element must pass my custom validation"]
          expect(eapi.errors.messages).to eq({other: ["element must pass my custom validation"]})

          eapi.other [:valid_val]
          expect(eapi).to be_valid
        end
      end
    end
  end

end