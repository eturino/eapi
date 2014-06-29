# Eapi (Elastic API)

ruby gem for building complex structures that will end up in hashes (initially devised for ElasticSearch search requests)

[![Gem Version](https://badge.fury.io/rb/eapi.svg)](http://badge.fury.io/rb/eapi)
[![Build Status](https://travis-ci.org/eturino/eapi.svg?branch=master)](https://travis-ci.org/eturino/eapi)
[![Code Climate](https://codeclimate.com/github/eturino/eapi.png)](https://codeclimate.com/github/eturino/eapi)
[![Code Climate Coverage](https://codeclimate.com/github/eturino/eapi/coverage.png)](https://codeclimate.com/github/eturino/eapi)
[![Coverage Status](https://coveralls.io/repos/eturino/eapi/badge.png)](https://coveralls.io/r/eturino/eapi)

## Installation

Add this line to your application's Gemfile:

    gem 'eapi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eapi

## Dependencies

This gem uses ActiveSupport (version 4) and also the ActiveModel Validations (version 4)

Extracted from the gemspec:
```
spec.add_dependency 'activesupport', '~> 4'
spec.add_dependency 'activemodel', '~> 4'
```

## Usage

TODO: Write usage instructions here

### including EAPI into your class

Just include the module `Eapi::Common` into your class.

```ruby    
class MyTestKlass
  include Eapi::Common

  property :something
end
```

### Initialize

`Eapi::Common` will add a `initialize` method to your class that will accept a hash. It will recognise the defined properties in that hash and will set them. 

For now any unrecognised property in the hash will be ignored. This may change in the future.

```ruby    
class MyTestKlass
  include Eapi::Common

  property :something
end

x = MyTestKlass.new something: 1
x.something # => 1
```

### Object creation shortcut: calling methods in Eapi

Calling a method with the desired class name in `Eapi` module will do the same as `DesiredClass.new(...)`. The name can be the same as the class, or an underscorised version, or a simple underscored one.  

The goal is to use `Eapi.esr_search(name: 'Paco')` as a shortcut to `Esr::Search.new(name: 'Paco')`. We can also use `Eapi.Esr_Search(...)` and other combinations.

To show this feature and all the combinations for method names, we'll use the 2 example classes that are used in the actual test rspec.

```ruby
class MyTestKlassOutside
  include Eapi::Common

  property :something
end

module Somewhere
  class TestKlassInModule
    include Eapi::Common

    property :something
  end
end
```

As shown by rspec run:

```
    initialise using method calls to Eapi
      Eapi.MyTestKlassOutside(...)
        calls MyTestKlassOutside.new
      Eapi.my_test_klass_outside(...)
        calls MyTestKlassOutside.new
      Eapi.Somewhere__TestKlassInModule(...)
        calls Somewhere::TestKlassInModule.new
      Eapi.somewhere__test_klass_in_module(...)
        calls Somewhere::TestKlassInModule.new
      Eapi.Somewhere_TestKlassInModule(...)
        calls Somewhere::TestKlassInModule.new
      Eapi.somewhere_test_klass_in_module(...)
        calls Somewhere::TestKlassInModule.new
```

### Defining properties

We define properties in our class with the instruction `property` as shown:

```ruby
class MyTestKlass
  include Eapi::Common

  property :one
  property :two
end
```
#### Setting proeprties on object creation
We can then assign the properties on object creation:
```ruby
x = MyTestKlass.new one: 1, two: 2
```
#### Getters

A getter method will be created for each property
```ruby
x = MyTestKlass.new one: 1, two: 2
x.one # => 1
x.two # => 2
```

#### Setters

Also, a setter will be created for each property
```ruby
x = MyTestKlass.new one: 1, two: 2
x.one = :other
x.one # => :other
```

#### Fluent setters (for method chaining)
Besides the normal setter, a fluent setter (`set_my_prop`) will be created for each property. `self` is returned on this setters, enabling Method Chaining.

```ruby
x = MyTestKlass.new one: 1, two: 2
res = x.set_one(:other)
x.one # => :other
res.equal? x # => true

x.set_one(:hey).set_two(:you)
x.one # => :hey
x.two # => :you
```

#### Getter method as fluent setter

The getter method also works as fluent setter. If we pass an argument to it, it will call the fluent setter
```ruby
x = MyTestKlass.new
res = x.one :fluent
x.one # => :fluent
res.equal? x # => true
```

### Convert to hashes: `to_h` and `create_hash`

All Eapi classes respond to `to_h` and return a hash, as it is the main purpose of this gem. It will execute any validation (see property definition), and if everything is ok, it will convert it to a simple hash structure.
 
#### Methods involved

Inside, `to_h` will call `valid?`, raise an error of type `Eapi::Errors::InvalidElementError` if something is not right, and if everything is ok it will call `create_hash`.

The `create_hash` method will create a hash with the properties as keys. Each value will be "converted".

#### Values conversion

By default, each property will be converted into a simple element (Array, Hash, or simple value).  

If a value is an Array or a Set, `to_a` will be invoked and all values will be "converted" in the same way.

If a value respond to `to_h`, it will be called. That way, if the value of a property (or an element of an Array) is an Eapi object, it will be validated and converted into a simple hash structure.

important: *any nil value will be omitted* in the final hash.

#### Example

To demonstrate this behaviour we'll have an Eapi enabled class `ExampleEapi` and another `ComplexValue` class that responds to `to_h`. We'll set into the `ExampleEapi` object complex properties to demonstrate the conversion into a simple structure.

```ruby
class ComplexValue
  def to_h
    {
      a: Set.new(['hello', 'world', MyTestObject.new])
    }
  end
end

class ExampleEapi
  include Eapi::Common

  property :something, required: true
  property :other
end

# TESTING `to_h`

list = Set.new [
                 OpenStruct.new(a: 1, 'b' => 2),
                 {c: 3, 'd' => 4},
                 nil
               ]

eapi = ExampleEapi.new something: list, other: ComplexValue.new
eapi.to_h # => 
# {
#   something: [
#                {a: 1, b: 2},
#                {c: 3, d: 4},
#              ],
# 
#   other:     {
#                a: [
#                     'hello',
#                     'world',
#                     {a: 'hello'}
#                   ]
#              }
# }
```

### Property definition

When defining the property, we can specify some options to specify what values are expected in that property. This serves for validation and automatic initialisation.

It uses `ActiveModel::Validations`. When `to_h` is called in an Eapi object, the `valid?` method will be called and if the object is not valid an `Eapi::Errors::InvalidElementError` error will raise.

#### Mark a property as Required with `required` option

A required property will fail if the value is not present. It will use `ActiveModel::Validations` inside and will effectively do a `validates_presence_of :property_name`. 

example:

```ruby
class TestKlass
  include Eapi::Common

  property :something, required: true
end

eapi = TestKlass.new
eapi.valid? # => false
eapi.errors.full_messages # => ["Something can't be blank"]
eapi.errors.messages # => {something: ["can't be blank"]}
```

#### Specify the property's Type with `type` option

If a property is defined to be of a specific type, the value will be validated to meet that criteria. It means that the value must be of the specified type. `value.kind_of?(type)`

example:
 
```ruby
class TestKlass
  include Eapi::Common

  property :something, type: Hash
end

eapi = TestKlass.new something: 1
eapi.valid? # => false
eapi.errors.full_messages # => ["Something must be a Hash"]
eapi.errors.messages # => {something: ["must be a Hash"]}
```

#### Custom validation with `validate_with` option

A more specific validation can be used using `validate_with`, that works the same way as `ActiveModel::Validations`. 

example:
 
```ruby
class TestKlass
  include Eapi::Common

  property :something, validate_with: ->(record, attr, value) do
    record.errors.add(attr, "must pass my custom validation") unless value == :valid_val
  end
end

eapi = TestKlass.new something: 1
eapi.valid? # => false
eapi.errors.full_messages # => ["Something must pass my custom validation"]
eapi.errors.messages # => {something: ["must pass my custom validation"]}
```

#### Validations from `ActiveModel::Validations`

All other ActiveModel::Validations can be used:

```ruby
class MyTestClassVal5
  include Eapi::Common

  property :something
  validates :something, numericality: true

end

eapi = MyTestClassVal5.new something: 'something'
eapi.valid? # => false
eapi.errors.full_messages # => ["Something is not a number"]
eapi.errors.messages # => {something: ["must is not a number"]}
```

#### List properties

TODO Doc


## Contributing

1. Fork it ( https://github.com/eturino/eapi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
