require 'spec_helper'

RSpec.describe Eapi do

  context 'list' do

    class MyListKlass
      include Eapi::List
    end

    describe 'list behaviour' do
      subject { MyListKlass.new }

      context '#<<' do
        it 'append element, normal behaviour' do
          res = subject << :hey
          expect(res).to eq [:hey]
          expect(subject.to_a).to eq [:hey]
        end
      end

      context '#add' do
        it 'fluent adder, returns self' do
          res = subject.add(:hey).add(:you)
          expect(res).to eq subject
          expect(subject.to_a).to eq [:hey, :you]
        end
      end

      context '#to_a' do
        it 'executes validation' do

        end
      end
    end

    describe 'list methods' do
      KNOWN_METHODS = {
        not_supported: [:transpose, :assoc, :rassoc, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :pack],
        not_same:      [:pry, :to_s, :inspect, :to_a, :to_h, :hash, :eql?, :to_ary, :pretty_print, :pretty_print_cycle],
        block:         [:cycle, :each, :each_index, :reverse_each],
        special:       [:[], :[]=, :<<, :==],
        other_array:   [:concat, :+, :-, :&, :|, :replace, :<=>],
        at:            [:at, :fetch, :delete_at, :from, :to],
        index:         [:index, :find_index, :rindex, :delete],
        push:          [:push, :unshift, :append, :prepend],
        insert:        [:insert],
        map:           [:map, :map!, :collect!, :collect],
        select!:       [:keep_if, :select!, :reject!, :select, :delete_if, :reject, :drop_while, :take_while, :bsearch],
        by_number:     [:in_groups_of, :in_groups, :drop, :take, :include?, :*, :to_query, :fill],
        slice:         [:slice, :slice!],
        sort_by:       [:sort_by!],
        sample:        [:sample],
        shuffle:       [:shuffle, :shuffle!],
      }

      SUPPORTED_METHODS = [].public_methods(false) - KNOWN_METHODS[:not_supported]
      MIMIC_METHODS     = [].public_methods(false) - KNOWN_METHODS.values.flatten

      subject { MyListKlass.new.add(1).add(2).add(3) }
      let(:other) { MyListKlass.new.add(1).add(2).add(3) }
      let(:array) { [1, 2, 3] }

      context 'array methods' do
        describe 'respond to methods' do
          KNOWN_METHODS[:not_supported].each do |m|
            it "does not respond to #{m}" do
              expect(subject).not_to respond_to(m)
            end
          end

          SUPPORTED_METHODS.each do |m|
            it "responds to #{m}" do
              expect(subject).to respond_to(m)
            end
          end
        end

        describe 'same behaviour as list array' do

          describe 'to_ary' do
            it { expect(subject.to_ary).to eq array }
            it { expect(subject.to_ary).not_to equal subject }
            it { expect(subject.to_ary).to equal subject._list }
          end

          describe 'method ==' do
            it { expect(subject).to eq array }
            it { expect(subject).to eq other }
            it { expect(subject).not_to eq [3, 2, 1] }
            it { expect(subject).not_to eq MyListKlass.new }
          end

          describe 'method []' do
            it { expect(subject[2]).to eq array[2] }
          end

          describe 'method []=' do
            it { expect(subject[2] = :paco).to eq(array[2] = :paco) }
            it do
              subject[2] = :paco
              expect(subject[2]).to eq :paco
            end
          end

          describe 'method <<' do
            it { expect(subject << :paco).to eq(array << :paco) }
            it do
              subject << :paco
              expect(subject.last).to eq :paco
            end
          end

          KNOWN_METHODS[:other_array].each do |m|
            describe "method #{m}" do
              it { expect(subject.public_send(m, other)).to eq array.public_send(m, other._list) }
              it { expect(subject.public_send(m, other._list)).to eq(array.public_send(m, other._list)) }
            end
          end


          KNOWN_METHODS[:at].each do |m|
            describe "method #{m}" do
              it { expect(subject.public_send(m, 2)).to eq array.public_send(m, 2) }
            end
          end

          KNOWN_METHODS[:index].each do |m|
            describe "method #{m}" do
              it { expect(subject.public_send(m, 2)).to eq array.public_send(m, 2) }
            end
          end

          KNOWN_METHODS[:push].each do |m|
            describe "method #{m}" do
              it { expect(subject.public_send(m, :paco)).to eq(array.public_send(m, :paco)) }
              it do
                subject.public_send(m, :paco)
                array.public_send(m, :paco)
                expect(subject).to eq array
              end
            end
          end

          KNOWN_METHODS[:insert].each do |m|
            describe "method #{m}" do
              it { expect(subject.public_send(m, 1, :paco)).to eq(array.public_send(m, 1, :paco)) }
              it do
                subject.public_send(m, 1, :paco)
                array.public_send(m, 1, :paco)
                expect(subject).to eq array
              end
            end
          end

          describe "method sample" do
            it do
              expect(subject._list).to include(subject.sample)
            end
          end

          describe "method shuffle" do
            it do
              list_before_shuffle = subject._list.dup
              list_after_shuffle  = subject.shuffle._list.dup
              expect(list_before_shuffle.sort).to eq list_after_shuffle.sort
            end
          end

          describe "method shuffle!" do
            it do
              list_before_shuffle = subject._list.dup
              subject.shuffle!
              list_after_shuffle = subject._list.dup
              expect(list_before_shuffle.sort).to eq list_after_shuffle.sort
            end
          end


          KNOWN_METHODS[:map].each do |m|
            describe "method #{m}" do
              let(:subject_applied_block) do
                subject.public_send(m) { |x| x + 1 }
              end

              let(:array_applied_block) do
                array.public_send(m) { |x| x + 1 }
              end

              it do
                expect(subject_applied_block).to eq array_applied_block
              end

              it do
                subject_applied_block
                array_applied_block
                expect(subject).to eq array
              end
            end
          end


          KNOWN_METHODS[:select!].each do |m|
            describe "method #{m}" do
              let(:subject_applied_block) do
                subject.public_send(m) { |x| x.odd? }
              end

              let(:array_applied_block) do
                array.public_send(m) { |x| x.odd? }
              end

              it do
                expect(subject_applied_block).to eq array_applied_block
              end

              it do
                subject_applied_block
                array_applied_block
                expect(subject).to eq array
              end
            end
          end


          KNOWN_METHODS[:by_number].each do |m|
            describe "method #{m}" do
              let(:subject_result) do
                subject.public_send(m, 2)
              end

              let(:array_result) do
                array.public_send(m, 2)
              end

              it do
                expect(subject_result).to eq array_result
              end

              it do
                subject_result
                array_result
                expect(subject).to eq array
              end
            end
          end


          KNOWN_METHODS[:slice].each do |m|
            describe "method #{m}" do
              let(:subject_result) do
                subject.public_send(m, 2)
              end

              let(:array_result) do
                array.public_send(m, 2)
              end

              it do
                expect(subject_result).to eq array_result
              end

              it do
                subject_result
                array_result
                expect(subject).to eq array
              end
            end
          end

          describe "method sort_by!" do
            let(:subject_enumerator) do
              subject.sort_by!
            end

            let(:array_enumerator) do
              array.sort_by!
            end

            let(:subject_with_block) do
              subject.sort_by! { |x| -1 * x }
            end

            let(:array_with_block) do
              array.sort_by! { |x| -1 * x }
            end

            it do
              expect(subject_enumerator.to_a).to eq array_enumerator.to_a
            end

            it do
              expect(subject_with_block.to_a).to eq array_with_block.to_a
            end

            it do
              subject_with_block
              array_with_block
              expect(subject).to eq array
            end
          end


          describe 'block methods' do
            describe 'method cycle' do
              it 'behaves like the method in Array' do
                sl = []
                al = []
                subject.cycle(2) { |x| sl << (x + 1) }
                array.cycle(2) { |x| al << (x + 1) }

                expect(sl).to eq al
              end
            end
          end


          MIMIC_METHODS.each do |m|
            describe "method #{m}" do
              it 'behaves like the method in Array' do
                lr = subject.public_send m
                ar = array.public_send m

                if ar.equal? array
                  expect(lr).to equal subject
                else
                  expect(lr).to eq ar
                end

                expect(subject._list).to eq array
              end
            end
          end
        end
      end
    end

    describe 'list definition' do
      class ListDefinitionTestKlass
        include Eapi::List

        elements required: true, type: String, unique: true
      end

      let(:definition) { {required: true, type: String, unique: true} }

      subject { ListDefinitionTestKlass.new }

      context '.is_multiple?' do
        it { expect(subject.class).to be_is_multiple }
      end

      context '.definition_for_elements' do
        it { expect(subject.class.definition_for_elements).to eq definition }
      end

      context 'required' do
        it 'fails if empty' do
          expect(subject).not_to be_valid
          subject.add "Something"
          expect(subject).to be_valid
        end
      end

      context 'type' do
        it 'fails if any element is not of valid type' do
          subject.add "Something"
          subject.add :is
          subject.add 1
          expect(subject).not_to be_valid
          subject.clear
          subject.add "Just Strings"
          subject.add "Many Strings"
          expect(subject).to be_valid
        end

        context 'with option allow_raw (default false)' do
          class AllowRawValueKlass
            include Eapi::Item
            property :something
          end

          class ListAllowRawTestKlass
            include Eapi::List

            elements type: AllowRawValueKlass, allow_raw: true
          end

          subject { ListAllowRawTestKlass.new }

          it 'allows a Hash or Array value with type check' do
            subject.add(1)
            expect(subject).not_to be_valid

            subject.clear.add(AllowRawValueKlass.new)
            expect(subject).to be_valid

            subject.clear.add([1, 2, 3]).add({a: :hash})
            expect(subject).to be_valid
          end

          it 'can be allowed and disallowed after definition' do
            orig = ListAllowRawTestKlass.elements_allow_raw?
            ListAllowRawTestKlass.elements_allow_raw
            expect(ListAllowRawTestKlass).to be_elements_allow_raw
            ListAllowRawTestKlass.elements_disallow_raw
            expect(ListAllowRawTestKlass).not_to be_elements_allow_raw

            if orig
              ListAllowRawTestKlass.elements_allow_raw
            else
              ListAllowRawTestKlass.elements_disallow_raw
            end
          end
        end
      end

      context 'unique' do
        it 'fails if has any repeated elements' do
          subject.add "Cramer"
          subject.add "vs"
          subject.add "Cramer"

          expect(subject).not_to be_valid

          msgs = {:_list => ["elements must be unique (repeated elements: {\"Cramer\"=>2})"]}
          expect(subject.errors.messages).to eq msgs

          subject.clear

          subject.add "Cramer"
          subject.add "vs"
          subject.add "Other Guy"

          expect(subject).to be_valid
        end
      end

      context 'validate_with lambda' do
        class MyTestClassListValElements
          include Eapi::List
          elements validate_with: ->(record, attr, value) do
            record.errors.add(attr, "element must pass my custom validation") unless value == :valid_val
          end
        end

        it 'will run that custom validation for all the elements in the list' do
          eapi = MyTestClassListValElements.new
          eapi.add 1
          expect(eapi).not_to be_valid
          expect(eapi.errors.full_messages).to eq [" list element must pass my custom validation"]
          expect(eapi.errors.messages).to eq({_list: ["element must pass my custom validation"]})

          eapi.clear.add :valid_val
          expect(eapi).to be_valid
        end
      end

    end

    describe 'render' do
      class TestListItemRender
        include Eapi::Item

        property :something
        property :other

        def perform_render
          {something => other}
        end
      end

      class TestListRender
        include Eapi::List

        elements type: 'TestListItemRender'
      end

      let(:item) { TestListItemRender.new something: :f, other: :o }
      subject { TestListRender.new.add(item) }
      let(:expected) { [{f: :o}] }

      it 'renders to an array, rendering each element' do
        expect(subject.render).to eq expected
      end
    end
  end
end