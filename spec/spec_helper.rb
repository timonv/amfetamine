require File.expand_path("../../lib/dada.rb", __FILE__)
require 'dummy/dummy'
require 'fakeweb'
require 'json'

#Fakeweb to stub server responses, still want to to integration tests on the rest client
def build(object)
  {
    :dummy => lambda { Dummy.new({:title => 'Dummy', :description => 'Crash me!', :id => Dummy.children.length + 1})}
  }[object].call
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.after(:each) { Dada::Config.memcached_instance.flush }
end

FakeWeb.allow_net_connect = false # No real connects

def stub_single_response(object)
  FakeWeb.register_uri(:get, %r|http://test\.local/dummies/#{object.id}|, :body => { :dummy => object.to_hash }.to_json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_all_response(*objects)
  json = JSON.generate(objects.inject([]) { |acc,o| acc << o })
  FakeWeb.register_uri(:get, "http://test.local/dummies", :body => json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_all_nil_response
  FakeWeb.register_uri(:get, 'http://test.local/dummies', :body => [].to_json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_nil_response
  FakeWeb.register_uri(:get, %r|http://test\.local/dummies/\d*|, :body => nil, :status => ["404", "Not Found"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end