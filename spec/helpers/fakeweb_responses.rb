FakeWeb.allow_net_connect = false # No real connects

# I know, duplication, right? just lazy.

def stub_single_response(object)
  FakeWeb.register_uri(:get, %r|http://test\.local/dummies/#{object.id}|, :body => { :dummy => object.to_hash }.to_json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_all_response(*objects)
  #json = JSON.generate(objects.inject([]) { |acc,o| acc <<  })
  json = objects.inject([]) { |acc, o| acc << o.as_json(:root => o.class.model_name.element, :methods => [:id]) }.to_json
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

def stub_post_response(object=nil)
  path = '/dummies'
  if object
    path = object.rest_path
    if object.belongs_to_relationship?
      path = object.belongs_to_relationships.first.rest_path
    end
  end
  FakeWeb.register_uri(:post, "http://test.local#{path}", :body => object ? object.to_json : nil, :status => ["201", "Object created"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_post_errornous_response
  FakeWeb.register_uri(:post, "http://test.local/dummies", :body => {:description => 'can\'t be empty'}.to_json, :status => ["422", "Validation Errors"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_update_response(object=nil)
  FakeWeb.register_uri(:put, %r|http://test\.local/dummies/\d*|, :body => object ? object.to_json : nil, :status => ["200", "Object updated"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_update_errornous_response
  FakeWeb.register_uri(:put, %r|http://test\.local/dummies/\d*|, :body => {:title => 'can\'t be empty'}.to_json, :status => ["422", "Validation Errors"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_delete_response(object=nil)
  path = '/dummies'
  if object
    path = object.rest_path
    if object.belongs_to_relationship?
      path = object.belongs_to_relationships.first.rest_path
    end
  end
  FakeWeb.register_uri(:delete, %r|http://test\.local#{path}/\d*|, :body => nil, :status => ["200", "Object deleted"], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_delete_errornous_response
  FakeWeb.register_uri(:delete, %r|http://test\.local/dummies/\d*|, :body => nil, :status => ["500", "Can't delete it :("], :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_nested_all_response(parent,*children)
  json = children.inject([]) { |acc, o| acc << o.as_json(:root => o.class.model_name.element, :methods => [:id]) }.to_json
  FakeWeb.register_uri(:get, "http://test.local/#{parent.class.name.to_s.downcase.pluralize}/#{parent.id}/#{children.first.class.name.downcase.pluralize}", :body => json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_nested_single_response(parent,child)
  FakeWeb.register_uri(:get, %r|http://test\.local/#{parent.class.name.to_s.downcase.pluralize}/#{parent.id}/#{child.class.name.downcase.pluralize}/#{child.id}|, :body => { child.class.name.downcase.to_sym => child.to_hash }.to_json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_conditional_all_response(query, *objects)
  #json = JSON.generate(objects.inject([]) { |acc,o| acc <<  })
  json = objects.inject([]) { |acc, o| acc << o.as_json(:root => o.class.model_name.element, :methods => [:id]) }.to_json
  FakeWeb.register_uri(:get, %r|http://test.local/dummies\?.*|, :body => json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_conditional_nested_all_response(parent,query, *children)
  json = children.inject([]) { |acc, o| acc << o.as_json(:root => o.class.model_name.element, :methods => [:id]) }.to_json
  FakeWeb.register_uri(:get, %r|http://test.local/#{parent.class.name.to_s.downcase.pluralize}/#{parent.id}/#{children.first.class.name.downcase.pluralize}\?.*|, :body => json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_conditional_single_response(object, query)
  #json = JSON.generate(objects.inject([]) { |acc,o| acc <<  })
  FakeWeb.register_uri(:get, %r|http://test.local/dummies/\d{1,2}\?.+|, :body => object.to_json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end

def stub_conditional_nested_single_response(parent,child, query)
  FakeWeb.register_uri(:get, %r|http://test.local/#{parent.class.name.to_s.downcase.pluralize}/#{parent.id}/#{child.class.name.downcase.pluralize}/\d{1,2}\?.*|, :body => child.to_json, :content_type => 'application/json')
  yield
  FakeWeb.clean_registry
end
