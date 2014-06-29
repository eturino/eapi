require 'spec_helper'

RSpec.describe Eapi do
  class SomeType
  end

  context 'type check' do
    class MyTestTypeKlass
      include Eapi::Common
      is :one_thing, :other_thing, SomeType
    end

    describe '#is? and .is?' do
      it 'true if asked for the same type' do
        expect(MyTestTypeKlass).to be_is MyTestTypeKlass
        expect(MyTestTypeKlass).to be_is 'MyTestTypeKlass'
        expect(MyTestTypeKlass).to be_is :MyTestTypeKlass
        expect(MyTestTypeKlass).to be_is :my_test_type_klass
      end

      it 'false if asked for other class' do
        expect(MyTestTypeKlass).not_to be_is Hash
        expect(MyTestTypeKlass).not_to be_is 'Hash'
        expect(MyTestTypeKlass).not_to be_is :Hash
      end

      it 'true if asked for a type specified on the class with `is` method' do
        expect(MyTestTypeKlass).not_to be_is :not_you
        expect(MyTestTypeKlass).to be_is :one_thing
        expect(MyTestTypeKlass).to be_is :other_thing
        expect(MyTestTypeKlass).to be_is SomeType
        expect(MyTestTypeKlass).to be_is :SomeType
      end
    end

    describe '#is?' do
      it 'behaves exactly like class method `.is?`' do
        obj = MyTestTypeKlass.new

        expect(obj).to be_is MyTestTypeKlass
        expect(obj).to be_is 'MyTestTypeKlass'
        expect(obj).to be_is :MyTestTypeKlass
        expect(obj).to be_is :my_test_type_klass

        expect(obj).not_to be_is Hash
        expect(obj).not_to be_is 'Hash'
        expect(obj).not_to be_is :Hash

        expect(obj).not_to be_is :not_you
        expect(obj).to be_is :one_thing
        expect(obj).to be_is :other_thing
        expect(obj).to be_is SomeType
        expect(obj).to be_is :SomeType
      end
    end

    describe '`#is_a_specific_type?` and `#is_an_other_type?`' do
      it 'will use #is? inside' do
        obj = MyTestTypeKlass.new
        expect(obj).to be_is_a_my_test_type_klass
        expect(obj).not_to be_is_a_not_you
        expect(obj).to be_is_an_one_thing
        expect(obj).to be_is_an_other_thing
      end

      it 'method_missing still works' do
        expect { MyTestTypeKlass.new.some_other_method? }.to raise_exception(NoMethodError)
      end
    end

    describe '`.is_a_specific_type?` and `.is_an_other_type?`' do
      it 'will use .is? inside' do
        expect(MyTestTypeKlass).to be_is_a_my_test_type_klass
        expect(MyTestTypeKlass).not_to be_is_a_not_you
        expect(MyTestTypeKlass).to be_is_an_one_thing
        expect(MyTestTypeKlass).to be_is_an_other_thing
      end

      it 'method_missing still works' do
        expect { MyTestTypeKlass.some_other_method? }.to raise_exception(NoMethodError)
      end
    end
  end

  context 'using symbol as type' do
    class MyTestTypeKlassSymbol
      include Eapi::Common
      is :SomeType
    end

    it 'works the same' do
      expect(MyTestTypeKlassSymbol).to be_is SomeType
      expect(MyTestTypeKlassSymbol).to be_is :SomeType

      obj = MyTestTypeKlassSymbol.new
      expect(obj).to be_is SomeType
      expect(obj).to be_is :SomeType
    end
  end
end