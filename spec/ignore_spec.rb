require 'spec_helper'

RSpec.describe Eapi do

  class IgnoreSpecTestItemDefault
    include Eapi::Item
    property :something
  end

  class IgnoreSpecTestItemFalse
    include Eapi::Item
    property :something, ignore: false
  end

  class IgnoreSpecTestItemSymbol
    include Eapi::Item
    property :something, ignore: :blank?
  end

  class IgnoreSpecTestItemProc
    include Eapi::Item
    property :something, ignore: Proc.new { |x| x.to_s == 'ignoreme' }
  end

  class IgnoreSpecTestListDefault
    include Eapi::List
  end

  class IgnoreSpecTestListFalse
    include Eapi::List

    elements ignore: false
  end

  class IgnoreSpecTestListSymbol
    include Eapi::List

    elements ignore: :blank?
  end

  class IgnoreSpecTestListProc
    include Eapi::List

    elements ignore: Proc.new { |x| x.to_s == 'ignoreme' }
  end


  describe 'ignore values on render' do
    describe 'default (no specification in definition)' do
      describe 'Item' do
        subject { IgnoreSpecTestItemDefault.new }
        it 'ignore nil values' do
          subject.something nil
          expect_not_in_hash
        end

        it 'does not ignore any other value' do
          subject.something 1
          expect_in_hash
        end
      end

      describe 'List' do
        subject { IgnoreSpecTestListDefault.new }
        it 'ignore nil values' do
          subject.add nil
          expect_not_in_array
        end

        it 'does not ignore any other value' do
          subject.add 1
          expect_in_array
        end
      end
    end

    describe 'message (symbol or string)' do
      describe 'Item' do
        subject { IgnoreSpecTestItemSymbol.new }
        it 'ignore if sending the message to the value returns truthy' do
          subject.something ""
          expect_not_in_hash
        end

        it 'does not ignore any other value' do
          subject.something 1
          expect_in_hash
        end
      end

      describe 'List' do
        subject { IgnoreSpecTestListSymbol.new }
        it 'ignore if sending the message to the value returns truthy' do
          subject.add ""
          expect_not_in_array
        end

        it 'does not ignore any other value' do
          subject.add 1
          expect_in_array
        end
      end
    end

    describe 'false' do
      describe 'Item' do
        subject { IgnoreSpecTestItemFalse.new }
        it 'do not ignore any value (even nils)' do
          subject.something nil
          expect_in_hash
        end

        it 'does not ignore any other value' do
          subject.something 1
          expect_in_hash
        end
      end

      describe 'List' do
        subject { IgnoreSpecTestListFalse.new }
        it 'do not ignore any value (even nils)' do
          subject.add nil
          expect_in_array
        end

        it 'does not ignore any other value' do
          subject.add 1
          expect_in_array
        end
      end
    end

    describe 'callable' do
      describe 'Item' do
        subject { IgnoreSpecTestItemProc.new }
        it 'ignore if the callable element with the value returns truthy' do
          subject.something :ignoreme
          expect_not_in_hash
        end

        it 'does not ignore any other value' do
          subject.something 1
          expect_in_hash
        end
      end

      describe 'List' do
        subject { IgnoreSpecTestListProc.new }
        it 'ignore if the callable element with the value returns truthy' do
          subject.add :ignoreme
          expect_not_in_array
        end

        it 'does not ignore any other value' do
          subject.add 1
          expect_in_array
        end
      end
    end
  end


  def expect_not_in_hash
    expect(subject.render.key? :something).to be false
  end

  def expect_in_hash
    expect(subject.render.key? :something).to be true
  end

  def expect_not_in_array
    expect(subject.render).to be_empty
  end

  def expect_in_array
    expect(subject.render).not_to be_empty
  end
end