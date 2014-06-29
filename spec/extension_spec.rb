require 'spec_helper'

RSpec.describe Eapi do

  context 'extension in other modules' do
    module MyExtension
      extend Eapi
    end

    class MyExtensionKlass
      include MyExtension::Common

      property :something
    end

    describe 'creates a MyExtension::Common module that works as Eapi::Common' do
      it 'adds classes that includes the new module to Eapi children' do
        expect(Eapi::Children).to be_has MyExtensionKlass
        expect(MyExtension::Children).to be_has MyExtensionKlass
      end
    end

    it 'allows the new module to be used for object creation shortcut' do
      obj = MyExtension.my_extension_klass something: 1
      expect(obj.to_h).to eq({something: 1})
    end
  end

end