require 'spec_helper'

RSpec.describe Eapi do

  context 'basic behaviour' do
    class MyTestKlassOutside
      include Eapi::Common

      property :something
    end

    describe 'Eapi::Children' do
      describe '#list' do
        it 'returns the list of Eapi enabled classes' do
          list = Eapi::Children.list
          expect(list).to include(MyTestKlassOutside)
        end
      end

      describe '#has?' do
        it 'true if the given class is an Eapi enabled class' do
          expect(Eapi::Children).not_to be_has('nope')
          expect(Eapi::Children).to be_has(MyTestKlassOutside)
          expect(Eapi::Children).to be_has('MyTestKlassOutside')
          expect(Eapi::Children).to be_has('my_test_klass_outside')
        end
      end

      describe '#get' do
        it 'get the given class if it is an Eapi enabled class' do
          expect(Eapi::Children.get('nope')).to be_nil
          expect(Eapi::Children.get(MyTestKlassOutside)).to eq MyTestKlassOutside
          expect(Eapi::Children.get('MyTestKlassOutside')).to eq MyTestKlassOutside
          expect(Eapi::Children.get('my_test_klass_outside')).to eq MyTestKlassOutside
        end
      end
    end

    describe 'Eapi.MyTestKlassOutside(...)' do
      it 'calls MyTestKlassOutside.new' do
        eapi = Eapi.MyTestKlassOutside(something: :hey)
        expect(eapi).to be_a MyTestKlassOutside
        expect(eapi.something).to eq :hey
      end
    end
  end

end