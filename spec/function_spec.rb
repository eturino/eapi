require 'spec_helper'

RSpec.describe Eapi do

  class MyTestKlassOutside
    include Eapi::Item

    property :something
  end

  class MyTestListOutside
    include Eapi::List
  end

  module Somewhere
    class TestKlassInModule
      include Eapi::Item

      property :something
    end

    class TestListInModule
      include Eapi::List
    end
  end

  describe 'Eapi::Children' do
    describe '#list' do
      it 'returns the list of Eapi enabled classes' do
        list = Eapi::Children.list
        expect(list).to include(MyTestKlassOutside)
        expect(list).to include(MyTestListOutside)
      end
    end

    describe '#has?' do
      it 'true if the given class is an Eapi enabled class' do
        expect(Eapi::Children).not_to be_has('nope')
        expect(Eapi::Children).to be_has(MyTestKlassOutside)
        expect(Eapi::Children).to be_has('MyTestKlassOutside')
        expect(Eapi::Children).to be_has('my_test_klass_outside')
        expect(Eapi::Children).to be_has(MyTestListOutside)
        expect(Eapi::Children).to be_has('MyTestListOutside')
        expect(Eapi::Children).to be_has('my_test_list_outside')
      end
    end

    describe '#get' do
      it 'get the given class if it is an Eapi enabled class' do
        expect(Eapi::Children.get('nope')).to be_nil
        expect(Eapi::Children.get(MyTestKlassOutside)).to eq MyTestKlassOutside
        expect(Eapi::Children.get('MyTestKlassOutside')).to eq MyTestKlassOutside
        expect(Eapi::Children.get('my_test_klass_outside')).to eq MyTestKlassOutside
        expect(Eapi::Children.get(MyTestListOutside)).to eq MyTestListOutside
        expect(Eapi::Children.get('MyTestListOutside')).to eq MyTestListOutside
        expect(Eapi::Children.get('my_test_list_outside')).to eq MyTestListOutside
      end
    end
  end

  describe 'initialise using method calls to Eapi', :focus do
    [
      [:MyTestKlassOutside, MyTestKlassOutside],
      [:my_test_klass_outside, MyTestKlassOutside],
      [:Somewhere__TestKlassInModule, Somewhere::TestKlassInModule],
      [:somewhere__test_klass_in_module, Somewhere::TestKlassInModule],
      [:Somewhere_TestKlassInModule, Somewhere::TestKlassInModule],
      [:somewhere_test_klass_in_module, Somewhere::TestKlassInModule],
    ].each do |(meth, klass)|
      describe "Eapi.#{meth}(...)" do
        it "calls #{klass}.new" do
          eapi = Eapi.send meth, something: :hey
          expect(eapi).to be_a klass
          expect(eapi.something).to eq :hey
        end
      end
    end

    [
      [:MyTestListOutside, MyTestListOutside],
      [:my_test_list_outside, MyTestListOutside],
      [:Somewhere__TestListInModule, Somewhere::TestListInModule],
      [:somewhere__test_list_in_module, Somewhere::TestListInModule],
      [:Somewhere_TestListInModule, Somewhere::TestListInModule],
      [:somewhere_test_list_in_module, Somewhere::TestListInModule],
    ].each do |(meth, klass)|
      describe "Eapi.#{meth}(...)" do
        it "calls #{klass}.new" do
          eapi = Eapi.send meth
          expect(eapi).to be_a klass
        end
      end
    end

    it 'will raise NoMethodError if a valid class is not found' do
      expect { Eapi.this_one_does_not_exist }.to raise_exception NoMethodError
    end
  end

end