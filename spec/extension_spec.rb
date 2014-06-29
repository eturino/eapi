require 'spec_helper'

RSpec.describe Eapi do

  context 'extension in other modules' do
    module MyExtension
      extend Eapi
    end

    class MyExtensionExternalKlass
      include MyExtension::Common

      property :something
    end

    module MyExtension
      class TestKlass
        include MyExtension::Common

        property :something
      end
    end

    describe 'creates a MyExtension::Common module that works as Eapi::Common' do
      it 'adds classes that includes the new module to Eapi children' do
        expect(Eapi::Children).to be_has MyExtensionExternalKlass
        expect(MyExtension::Children).to be_has MyExtensionExternalKlass

        expect(Eapi::Children).to be_has MyExtension::TestKlass
        expect(MyExtension::Children).to be_has MyExtension::TestKlass
      end
    end

    describe 'creation shortcut' do
      it 'allows the new module to be used for object creation shortcut' do
        obj = MyExtension.my_extension_external_klass something: 1
        expect(obj.to_h).to eq({something: 1})
      end

      describe 'if classes are inside the module, the name can be ignored with creation shortcut' do
        it 'MyExtension.test_klass(..) => MyExtension::TestKlass.new(..)' do
          obj = MyExtension.test_klass something: 1
          expect(obj).to be_a_kind_of MyExtension::TestKlass
          expect(obj.to_h).to eq({something: 1})
        end
      end
    end
  end

end