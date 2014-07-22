require 'spec_helper'

RSpec.describe Eapi do

  context '#to_h' do
    class MyTestClassToH
      include Eapi::Item

      property :something, required: true
      property :other
    end

    class MyTestObject
      def to_h
        {
          a: 'hello'
        }
      end
    end

    class MyTestObjectComplex
      def to_h
        {
          a: Set.new(['hello', 'world', MyTestObject.new])
        }
      end

      def expected
        {
          a: [
               'hello',
               'world',
               {a: 'hello'}
             ]
        }
      end
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

      eapi = MyTestClassToH.new
      eapi.something(MyTestObject.new).other(true)
      expected = {something: {a: 'hello'}, other: true}

      expect(eapi.to_h).to eq expected
    end

    it 'hash with elements, all converted to basic Arrays and Hashes (keys as symbols), and exluding nils (if all validations pass)' do
      list = Set.new [
                       OpenStruct.new(a: 1, 'b' => 2),
                       {c: 3, 'd' => 4},
                       nil
                     ]

      other = MyTestObjectComplex.new

      expected = {
        something: [
                     {a: 1, b: 2},
                     {c: 3, d: 4},
                   ],

        other:     other.expected
      }

      eapi = MyTestClassToH.new
      eapi.something list
      eapi.other other

      expect(eapi.to_h).to eq expected

    end
  end
end