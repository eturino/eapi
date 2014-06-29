require 'spec_helper'

RSpec.describe Eapi do

  context 'validations' do
    describe '#valid?' do
      it 'true if no validations' do
        class MyTestClassVal
          include Eapi::Common

          property :something
        end

        eapi = MyTestClassVal.new something: :hey
        expect(eapi).to be_valid
      end

      it 'false if validations not met' do
        class MyTestClassVal2
          include Eapi::Common

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
        include Eapi::Common

        property :something, required: true
      end

      eapi = MyTestClassVal3.new
      expect(eapi).not_to be_valid
      expect(eapi.errors.full_messages).to eq ["Something can't be blank"]
      expect(eapi.errors.messages).to eq({something: ["can't be blank"]})
    end

    it 'if type specified with a class, validates it' do
      class MyTestClassVal3
        include Eapi::Common

        property :something, type: Hash
      end

      eapi = MyTestClassVal3.new something: 1
      expect(eapi).not_to be_valid
      expect(eapi.errors.full_messages).to eq ["Something must be a Hash"]
      expect(eapi.errors.messages).to eq({something: ["must be a Hash"]})
    end

    it 'if validate_with: specified with a class, uses it to validate the property' do
      class MyTestClassVal4
        include Eapi::Common

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
        include Eapi::Common

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
  end

end