require 'spec_helper'

describe Dada::Relationships do
  let(:dummy) {build :dummy}
  let(:child) {build :child}
  
  context "Routing" do
    it "should generate correct paths" do
      dummy.children << child

      Child.rest_path.should == "/children"
      child.rest_path.should == "/dummies/#{dummy.id}/children"
      child.singular_path.should == "/dummies/#{dummy.id}/children/#{child.id}"
      Child.resource_suffix = '.json'
      child.rest_path.should == "/dummies/#{dummy.id}/children.json"
      child.singular_path.should == "/dummies/#{dummy.id}/children/#{child.id}.json"
      Child.resource_suffix = ''
    end
  end

  context "Adding and modifying children" do
    before(:each) do
      dummy.children << child
    end

    it "should be possible list all children" do
      dummy.children.should include(child)
      Dummy.cache.flush
      dummy.children.should include(child)
    end

    it "should build new child if asked" do
      new_child = dummy.build_child
      new_child.should be_new
      new_child.should be_a(Child)
      dummy.children
    end

    it "should create a new child if asked" do
      new_child = nil
      stub_post_response(child) do
        new_child = dummy.create_child
      end

      new_child.should_not be_new
      new_child.should be_cached
      dummy.children.should include(new_child)
      Dummy.cache.flush
      dummy.children.should include(new_child)
    end
  end
end


