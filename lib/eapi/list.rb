module Eapi
  module List
    include Comparable
    include Enumerable
    extend Common

    module ClassMethods
      def is_multiple?
        true
      end
    end

    def self.add_features(klass)
      Eapi::Common.add_features klass
      klass.extend(ClassMethods)
      klass.include(Eapi::Methods::Properties::ListInstanceMethods)
      klass.extend(Eapi::Methods::Properties::ListCLassMethods)
    end

    def self.extended(mod)
      def mod.included(klass)
        Eapi::List.add_features klass
      end
    end

    def self.included(klass)
      Eapi::List.add_features klass
    end

    def is_multiple?
      true
    end

    def to_a
      render
    end

    def _list
      @_list ||= []
    end

    def add(value)
      self << value
      self
    end

    def <=>(other)
      (_list <=> other) || (other.respond_to?(:_list) && _list <=> other._list)
    end

    # From Array

    # ary.replace(other_ary)  -> ary
    # ary.initialize_copy(other_ary)   -> ary
    #
    # Replaces the contents of +self+ with the contents of +other_ary+,
    # truncating or expanding if necessary.
    #
    #    a = [ "a", "b", "c", "d", "e" ]
    #    a.replace([ "x", "y", "z" ])   #=> ["x", "y", "z"]
    #    a                              #=> ["x", "y", "z"]
    def initialize_copy(other_ary)
      if other_ary.kind_of? List
        @_list = other_ary._list.dup
      elsif other_ary.respond_to? :to_a
        @_list = other_ary.to_a
      else
        raise ArgumentError, 'must be either a List or respond to `to_a`'
      end
    end

    protected :initialize_copy

    private
    def perform_render
      _list.reduce([]) do |array, value|
        set_value_in_final_array(array, value)
        array
      end
    end

    def perform_before_validation
      if self.class.prepare_value_for_elements?
        _list.map! { |v| prepare_value_for_element(v) }
      end
    end

    # transpose, assoc, rassoc , permutation, combination, repeated_permutation, repeated_combination, product, pack ?? => do not use the methods
  end

  class ListMethodDefiner

    DESTRUCTIVE_SELF_OR_NIL = [:uniq!, :compact!, :flatten!, :shuffle!, :concat, :clear, :replace, :fill, :reverse!, :rotate!, :sort!, :keep_if]

    DUP_METHODS = [:uniq, :compact, :flatten, :shuffle, :+, :-, :&, :|, :reverse, :rotate, :sort, :split, :in_groups, :in_groups_of, :from, :to]

    DELEGATED_METHODS = [
      # normal delegation
      :frozen?, :[], :[]=, :at, :fetch, :first, :last, :<<, :push, :pop, :shift, :unshift, :insert, :length, :size, :empty?, :rindex, :join, :collect, :map, :select, :values_at, :delete, :delete_at, :delete_if, :reject, :include?, :count, :sample, :bsearch, :to_json_without_active_support_encoder, :slice, :slice!, :sort_by!, :shuffle, :shuffle!,

      # for Enumerable
      :each, :each_index,

      # pose as array
      :to_ary, :*,

      # active support
      :shelljoin, :append, :prepend, :extract_options!, :to_sentence, :to_formatted_s, :to_default_s, :to_xml, :second, :third, :fourth, :fifth, :forty_two, :to_param, :to_query,

      # destructive that return selection
      :collect!, :map!, :select!, :reject!,
    ]

    def self.finalise(klass)
      delegate_methods_to_list klass
      pose_as_array klass
      destructive_self_or_nil klass
      dup_methods klass
    end

    private
    def self.delegate_methods_to_list(klass)
      klass.send :delegate, *DELEGATED_METHODS, to: :_list
    end


    def self.destructive_self_or_nil(klass)
      # Destructive methods that return self or nil
      DESTRUCTIVE_SELF_OR_NIL.each do |m|
        klass.send :define_method, m do |*args, &block|
          res = _list.send m, *args, &block
          res.nil? ? nil : self
        end
      end
    end

    def self.pose_as_array(klass)
      klass.send :alias_method, :index, :find_index
    end

    def self.dup_methods(klass)
      # Non destructive methods that return a new object
      DUP_METHODS.each do |m|
        klass.send :define_method, m do |*args, &block|
          dup.tap { |n| n.initialize_copy(n._list.send m, *args, &block) }
        end
      end
    end

  end

  ListMethodDefiner.finalise List
end