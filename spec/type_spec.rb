require 'spec_helper'

RSpec.describe Eapi do

  context 'type check' do
    class OtherType
    end

    class MyTestTypeKlass
      include Eapi::Common

      is :one_thing, :other_thing, OtherType
    end

    describe '#is? and .is?' do
      it 'true if asked for the same type' do
        expect(MyTestTypeKlass).to be_is MyTestTypeKlass
        expect(MyTestTypeKlass).to be_is 'MyTestTypeKlass'
        expect(MyTestTypeKlass).to be_is :MyTestTypeKlass

        obj = MyTestTypeKlass.new
        expect(obj).to be_is MyTestTypeKlass
        expect(obj).to be_is 'MyTestTypeKlass'
        expect(obj).to be_is :MyTestTypeKlass
      end

      it 'false if asked for other class' do
        expect(MyTestTypeKlass).not_to be_is Hash
        expect(MyTestTypeKlass).not_to be_is 'Hash'
        expect(MyTestTypeKlass).not_to be_is :Hash

        obj = MyTestTypeKlass.new
        expect(obj).not_to be_is Hash
        expect(obj).not_to be_is 'Hash'
        expect(obj).not_to be_is :Hash
      end

      it 'true if asked for a type specified on the class with `is` method' do
        expect(MyTestTypeKlass).not_to be_is :not_you
        expect(MyTestTypeKlass).to be_is :one_thing
        expect(MyTestTypeKlass).to be_is :other_thing
        expect(MyTestTypeKlass).to be_is OtherType
        expect(MyTestTypeKlass).to be_is :OtherType

        obj = MyTestTypeKlass.new
        expect(obj).not_to be_is :not_you
        expect(obj).to be_is :one_thing
        expect(obj).to be_is :other_thing
        expect(obj).to be_is OtherType
        expect(obj).to be_is :OtherType
      end
    end

  end

end