module Eapi
  module List
    include Comparable
    include Enumerable
    extend Common

    def render
      validate!
      create_array
    end

    alias_method :to_a, :render

    def create_array
      _list.map { |val| convert_value val }
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

    delegate :frozen?, :[], :[]=, :at, :fetch, :first, :last, :<<, :push, :pop, :shift, :unshift, :insert, :length, :size, :empty?, :rindex, :join, :collect, :map, :select, :values_at, :delete, :delete_at, :delete_if, :reject, :include?, :count, :sample, :bsearch, :to_json_without_active_support_encoder, :slice, :slice!, :sort_by!, :shuffle, :shuffle!,
             to: :_list

    # for Enumerable
    delegate :each, :each_index, to: :_list

    # to pose as Array
    alias_method :index, :find_index

    # pose as array
    delegate :to_ary, :*, to: :_list

    # array active support methods
    delegate :shelljoin, :append, :prepend, :extract_options!, :to_sentence, :to_formatted_s, :to_default_s, :to_xml, :second, :third, :fourth, :fifth, :forty_two, :to_param, :to_query,
             to: :_list


    # Destructive methods

    # ...that return self or nil
    [:uniq!, :compact!, :flatten!, :shuffle!, :concat, :clear, :replace, :fill, :reverse!, :rotate!, :sort!, :keep_if].each do |m|
      define_method m do |*args, &block|
        res = _list.send m, *args, &block
        res.nil? ? nil : self
      end
    end

    # ...that return the selection
    [:collect!, :map!, :select!, :reject!].each do |m|
      define_method m do |*args, &block|
        _list.send m, *args, &block
      end
    end

    # Non destructive methods that return a new object
    [:uniq, :compact, :flatten, :shuffle, :+, :-, :&, :|, :reverse, :rotate, :sort, :split, :in_groups, :in_groups_of, :from, :to].each do |m|
      define_method m do |*args, &block|
        dup.tap { |n| n.initialize_copy(n._list.send m, *args, &block) }
      end
    end


    # transpose, assoc, rassoc , permutation, combination, repeated_permutation, repeated_combination, product, pack ?? => do not use the methods

  end
end