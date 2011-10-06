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

def stub_post_response
  FakeWeb.register_uri(:post, "http://test.local/dummies", :body => nil, :status => ["201", "Object created"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_post_errornous_response
  FakeWeb.register_uri(:post, "http://test.local/dummies", :body => {:description => 'can\'t be empty'}.to_json, :status => ["400", "Validation Errors"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_update_response
  FakeWeb.register_uri(:put, %r|http://test\.local/dummies/\d*|, :body => nil, :status => ["200", "Object updated"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_update_errornous_response
  FakeWeb.register_uri(:put, %r|http://test\.local/dummies/\d*|, :body => {:title => 'can\'t be empty'}.to_json, :status => ["400", "Validation Errors"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end
