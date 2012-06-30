Amfetamine, A REST object abstractavaganza
====================================

> Makes your API calls f-f-f-ast!

Amfetamine adds an ActiveModel like interface to your REST services with support for any HTTP(arty) client and caching using memcached.

Sometimes you just quickly need to wrap up a REST api without having to worry about persistancy or the data. And since you want caching …

Note that the cache invalidates only when local changes are made. You could use a distributed cache or, more easilly, set a TTL on Dalli.

Features
--------

It is still in beta and under heavy development. Some features:

* Mapping of REST services to objects.
* HTTP configuration agnostic; it works with any configuration of HTTParty. It should work with any object that has a similar syntax.
* Reasonably effective object caching with memcached.
* It has a lot of methods that you expect from ActiveModel objects. Find, all, save, create, new, destroy, update_attributes, update.
* It supports all validation methods ActiveModel provides, thanks to ActiveModel -red.
* You can fully configure your memcached client, it uses Dalli.
* Although the client has been tested and build with JSON, it should support XML or Bson as well.
* It supports single nested resources for now.
* It supports conditions in the all and find method, just provide a :conditions hash like you're used to.
* Supports global HTTP and Memcached client as well as per object overriding.
* If a request passes validation on client side and not on service side, the client properly sets error messages from the service.
* Provides testing helpers
* Amfetamine supports some basic callbacks: before_save, after_save, around_save and before_create. More coming as needed.

Setup
=====

### 1)
Add it to your gemfile:

```ruby
gem 'amfetamine'
```

### 2)
Create an initializer, note that you can also do this on a per object basis:

```ruby
#config/initializers/amfetamine_config.rb
Amfetamine::Config.configure do |config|
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
class Banana < Amfetamine::Base
  # Right now methods are set dynamically, the older syntax is deprecated. Will move to an or/or situation.
  # OPTIONAL: Per object configuration
  amfetamine_configure memcached_instance: 'localhost:11211',
                 rest_client: BananaRestclient

end
```


### 4)
Lastly, because I think its more semantic, you need to configure both your service and client to include the root element in JSON. However, Amfetamine will work fine without this.

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
children.parent # => returns a Amfetamine::Relationship with only the parent
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

You can invalidate an object's cache any time by calling `clean_cache!` on an object. You can flush the whole cache by calling flush on either a class or Amfetamine::Cache.

Testing
=======

Amfetamine provides a testing helper to easilly stub out responses from external services, so you can better control what response you get.

```ruby
# Rspec:
before do
  AmfetamineObject.stub_responses! do |r|
    # Setting the code / path is optional. If amfetamine picks the wrong path, this will give you some weird errors.
    r.post(path: '/bananas/', code: 201) { some_object }
    r.get { some_object } # this sets to the default for gets on the rest_client this object uses
  end
end
```

Also, if you're using a cache, you should flush the cache before each test to avoid confusion.

Building Custom Methods
=======================

Its important to note that caching might not work as expected when building custom methods. For now, please refer to the code.

Testing
=======

Amfetamine provides several testing helpers to make testing easier. I didn't think it would be wise to allow external connections, but I didn't want you to have to stub out all methods either.

```ruby
Object.prevent_external_connections! # Raises an error if any external connections are made on this object

# You can provide a block as well, after the block the rest_client is set back to the default:
Object.prevent_external_connections! do |rest_client|
  rest_client.should_receive('get').with('/objects').and_return(objects.to_json)
  Object.all
end

# You can also use a dsl to predefine responses up front on a per object basis. You can use rspec 'let' objects in the response as well.
Object.stub_external_responses! do |r|
  r.get {object}
end

r.all # => object, also will yield an error, expects an array
r.find(1) # => object

# You can go wilder with this as well so you can allow multiple requests. You can also use this dsl on the rest_client in #prevent_external_connections!
Object.stub_external_responses! do |r|
  r.get(path: '/objects') { [object] } # Returns [object].to_json
  r.get(path: "/objects/#{object.id}", code: 404) {} # Returns a resource not found
end
```

TODO

Future Features & TODO
======================

* Smarter caching
* Better support for custom methods
* Support for Reddis
* Automatic determining of attributes and validations
* Supporting any amount of nested relationships
* Supporting interobject relationship (database versus service)
* More callbacks
* Better typecasting, it doesn't always work.
* Asynchronous requests
* Started out a lot smaller, metaprogramming needs to go composited.

Licence
=======


Copyright (C) 2012 Exvo.com, Timon Vonk

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Contributing
============

* Fork
* Test
* Code
* Test
* Pull Request

Contributors
============

* Timon Vonk
