Dada, A REST object abstractavaganza
====================================

>or da·da (dä'dä) 
>n.
>A European artistic and literary movement (1916-1923) that flouted conventional aesthetic and cultural values by producing works marked by nonsense, travesty, and incongruity.

Dada is an abstract art movement from the early 1900s, also, it provides object abstraction for you REST services. It does what activeresource does, but better, with caching. Dada is provided to your by Exvo, a cloud providing platform.

Features
--------

It is still in beta and under heavy development. Some features:

* Mapping of REST services to objects.
* HTTP configuration agnostic; it works with any configuration of HTTParty. It should work with any object that has a similar syntax.
* Reasonably effective object caching with memcached.
* It has a lot of methods that you expect from ActiveModel objects. Find, all, save, create, new, destroy, update_attributes, update.
* It supports all validation methods ActiveModel provides, thanks to ActiveModel -red.
* You can fully configure your memcached client, it uses Dalli.
* Although the client has been tested and build with JSON, it should support XML as well.
* It supports single nested resources for now.
* It supports conditions in the all method (find method asap), just provice a :conditions hash like you're used to.
* Supports global HTTP and Memcached client as well as per object overriding.
* If a request passes validation on client side and not on service side, the client properly sets error messages from the service.
* Provides testing helpers

Setup
=====

### 1)
Add it to your gemfile (not released yet):

```ruby
gem 'dada'
```

### 2)
Create an initializer dada_initializer.rb:

```ruby
Dada::Config.configure do |config|
  config.memcached_instance = [HOST:PORT, OPTION1,OPTION2] || HOST:PORT
  config.rest_client = REST_CLIENT

  # Optional
  config.resource_suffix = '.json' # The suffix to the path
  config.base_uri = 'http://bla.bla/bla/' # If you either need a path or domain infront of your URI, you can do it here. Its advised to use httparty for this.
end
```

### 3)
Configure your object:

```ruby
class Banana < Dada::Base
  # You need to setup an attribute for each attribute your object has, apart from id (thats _mandatory_)
  dada_attributes :name, :shape, :color, :created_at, :updated_at

  # OPTIONAL: Per object configuration
  configure_dada memcached_instance: 'localhost:11211',
                 rest_client: BananaRestclient

end
```


### 4)
NOW OPTIONAL: Because I think its more semantic, you need to configure both your service and client to include the root element in JSON.

```ruby
# config/initializers/wrap_parameters.rb
ActiveSupport.on_load(:action_controller) do
  wrap_parameters :format => [:json]
end
```

Usage
=====

### Relationships

```ruby
has_many_resources PLURAL_OBJECT_NAME_SYMBOLS
belongs_to_resource SINGULAR_OBJECT_NAME_SYMBOL

parent.children.all # => Returns all nested resources, you can enumarate it with each, include? and several other helpers are available
parent.children.all(:conditions => SOMETHING) # Works as expected
parent.children << child # Sets a child to a parent, child still needs to be saved. This will append it to the current all array and set the parent_id, accessing #all will overwrite that array.
parent.children.find(ID) # => Returns the nested child with ID
children.parent # => returns a Dada::Relationship with only the parent
```

### Querying

```ruby
Object.all # => returns all objects, request: /objects
Object.all(conditions: {:other_parent_id => 2} ) # => request: objects?other_parent_id=2
Object.find(ID) # => returns object with ID, request: objects/ID
```

### Modifying data

```ruby
object.save
object.destroy
object.update_attributes(HASH)
Object.create(HASH)
```

Cache Invalidation
=================

Objects are cached by request with the body as value. Request status codes are also cached. Every time an object is created, destroyed or updated, the plural cache is also invalidated.

You can invalidate an object's cache any time by calling `clean_cache!` on an object. You can flush the whole cache by calling flush on either a class or Dada::Cache.

Testing
=======

Dada provides a testing helper to easilly stub out responses from external services, so you can better control what response you get.

```ruby
# Rspec:
before do
  DadaObject.stub_responses! do |r|
    # Setting the code / path is optional. If dada picks the wrong path, this will give you some weird errors.
    r.post(path: '/bananas/', code: 201) { some_object }
    r.get { some_object } # this sets to the default for gets on the rest_client this object uses
  end
end
```

Also, if you're using a cache, you should flush the cache before each test to avoid confusion.

Building Custom Methods
=======================

Its important to note that caching might not work as expected when building custom methods. For now, please refer to the code.

TODO

Future Features
===============

* Smarter caching
* Better support for custom methods
* Support for Reddis
* Automatic determining of attributes and validations
* Supporting any amount of nested relationships
* Supporting interobject relationship (database versus service)

Licence
=======

TBD

Contributing
============

Please do a pull request and test your code!

Contributors
============

* Timon Vonk
