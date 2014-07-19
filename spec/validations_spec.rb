require 'spec_helper'

RSpec.describe Eapi do

  context 'validations' do
    describe '#valid?' do
      it 'true if no validations' do
        class MyTestClassVal
          include Eapi::Item

          property :something
        end

        eapi = MyTestClassVal.new something: :hey
        expect(eapi).to be_valid
      end

      it 'false if validations not met' do
        class MyTestClassVal2
          include Eapi::List

          property :something

          validates_presence_of :something
        end

        eapi = MyTestClassVal2.new
        expect(eapi).not_to be_valid
        expect(eapi.errors.full_messages).to eq ["Something can't be blank"]
        expect(eapi.errors.messages).to eq({something: ["can't be blank"]})
      end
    end

    it 'if required, same as validate presence' do
      class MyTestClassVal3
        include Eapi::List

        property :something, required: true
      end

      eapi = MyTestClassVal3.new
      expect(eapi).not_to be_valid
      expect(eapi.errors.full_messages).to eq ["Something can't be blank"]
      expect(eapi.errors.messages).to eq({something: ["can't be blank"]})
    end

    it 'if validate_with: specified with a class, uses it to validate the property' do
      class MyTestClassVal4
        include Eapi::List

        property :something, validate_with: ->(record, attr, value) do
          record.errors.add(attr, "must pass my custom validation") unless value == :valid_val
        end
      end

      eapi = MyTestClassVal4.new something: 1

      expect(eapi).not_to be_valid
      expect(eapi.errors.full_messages).to eq ["Something must pass my custom validation"]
      expect(eapi.errors.messages).to eq({something: ["must pass my custom validation"]})

      eapi.something :valid_val
      expect(eapi).to be_valid
    end

    it 'normal ActiveModel::Validations can be used' do
      class MyTestClassVal5
        include Eapi::List

        property :something

        validates :something, numericality: true

      end

      eapi = MyTestClassVal5.new something: 'something'

      expect(eapi).not_to be_valid
      expect(eapi.errors.full_messages).to eq ["Something is not a number"]
      expect(eapi.errors.messages).to eq({something: ["is not a number"]})

      eapi.something 1
      expect(eapi).to be_valid
    end

    context 'type is specified with a class' do
      class SimilarToHash
        def is?(type)
          [:SimilarToHash, :Hash].include? type.to_s.to_sym
        end
      end

      describe 'using a class as type' do
        class MyTestClassValType
          include Eapi::List

          property :something, type: Hash
        end

        it 'invalid if value is not of that type' do
          eapi = MyTestClassValType.new something: 1
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq ["Something must be a Hash"]
          expect(eapi.errors.messages).to eq({something: ["must be a Hash"]})
        end

        it 'valid if value is of the given type' do
          eapi = MyTestClassValType.new something: {}
          expect(eapi).to be_valid
        end

        it 'valid if value is not an instance of the given type but responds true to `.is?(type)`' do
          eapi = MyTestClassValType.new something: SimilarToHash.new
          expect(eapi).to be_valid
        end
      end


      describe 'using a symbol as type' do
        class MyTestClassValTypeSymbol
          include Eapi::List

          property :something, type: :Hash
        end

        it 'invalid if value is not of that type' do
          eapi = MyTestClassValTypeSymbol.new something: 1
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq ["Something must be a Hash"]
          expect(eapi.errors.messages).to eq({something: ["must be a Hash"]})
        end

        it 'valid if value is of the given type' do
          eapi = MyTestClassValTypeSymbol.new something: {}
          expect(eapi).to be_valid
        end

        it 'valid if value is not an instance of the given type but responds true to `.is?(type)`' do
          eapi = MyTestClassValTypeSymbol.new something: SimilarToHash.new
          expect(eapi).to be_valid
        end
      end


      describe 'using a string as type' do
        class MyTestClassValTypeString
          include Eapi::List

          property :something, type: 'Hash'
        end

        it 'invalid if value is not of that type' do
          eapi = MyTestClassValTypeString.new something: 1
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq ["Something must be a Hash"]
          expect(eapi.errors.messages).to eq({something: ["must be a Hash"]})
        end

        it 'valid if value is of the given type' do
          eapi = MyTestClassValTypeString.new something: {}
          expect(eapi).to be_valid
        end

        it 'valid if value is not an instance of the given type but responds true to `.is?(type)`' do
          eapi = MyTestClassValTypeString.new something: SimilarToHash.new
          expect(eapi).to be_valid
        end
      end


      describe 'using a string as type that is not a class' do
        class SomeValueSomethingTrue
          def is?(type)
            type.to_s == 'my_something'
          end
        end

        class SomeValueSomethingFalse
          def is?(type)
            type.to_s == 'not'
          end
        end

        class MyTestClassValTypeStringNotClass
          include Eapi::List

          property :something, type: 'my_something'
        end

        it 'valid if value returns true to `is?(type)`' do
          eapi = MyTestClassValTypeStringNotClass.new something: SomeValueSomethingTrue.new
          expect(eapi).to be_valid
        end

        it 'invalid if value returns false to `is?(type)`' do
          eapi = MyTestClassValTypeStringNotClass.new something: SomeValueSomethingFalse.new
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq ["Something must be a my_something"]
          expect(eapi.errors.messages).to eq({something: ["must be a my_something"]})
        end
      end
    end
  end

end