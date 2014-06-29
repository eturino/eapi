require 'spec_helper'

RSpec.describe Eapi do

  context '#to_h' do
    class MyTestClassToH
      include Eapi::Common

      property :something, required: true
      property :other
    end

    it 'raise error if invalid' do
      eapi = MyTestClassToH.new
      expect { eapi.to_h }.to raise_error do |error|
        expect(error).to be_a_kind_of Eapi::Errors::InvalidElementError
        expect(error.message).to be_start_with "errors: [\"Something can't be blank\"], self: #<MyTestClassToH"
      end

    end

    it 'create a hash with elements (calling to_h to each element), avoiding nils' do
      eapi = MyTestClassToH.new
      eapi.something 'hi'
      expected = {something: 'hi'}
      expect(eapi.to_h).to eq expected

      class MyTestObject
        def to_h
          'hello'
        end
      end

      element = MyTestObject.new
      eapi    = MyTestClassToH.new
      eapi.something(element).other(true)
      expected = {something: 'hello', other: true}

      expect(eapi.to_h).to eq expected
    end
  end
end