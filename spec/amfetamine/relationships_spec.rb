require 'spec_helper'

describe Amfetamine::Relationships do
  let(:dummy) {build :dummy}
  let(:child) {build :child}
  
  context "Routing" do
    it "should generate correct paths" do
      dummy.children << child

      Child.rest_path.should == "/children"
      child.rest_path.should == "/children"
      child.singular_path.should == "/children/#{child.id}"
      dummy.children.rest_path.should == "/dummies/#{dummy.id}/children"

      Child.resource_suffix = '.json'
      child.rest_path.should == "/children.json"
      dummy.children.rest_path.should == "/dummies/#{dummy.id}/children.json"
      child.singular_path.should == "/children/#{child.id}.json"

      Child.resource_suffix = ''
      child.dummy.singular_path.should == "/dummies/#{dummy.id}/children/#{child.id}"
      dummy.children.find_path(child.id).should == "/dummies/#{dummy.id}/children/#{child.id}"
    end

    it "should raise error if nested path lacks parent id" do
      child = Child.new({:title => 'test', :dummy_id => nil})

      lambda { child.belongs_to_relationships.first.rest_path }.should raise_exception(Amfetamine::InvalidPath)
    end
  end

  context "Adding and modifying children" do
    before(:each) do
      dummy.children << child
      child.instance_variable_set(:@notsaved, false)
    end

    it "should create a relationship if parent id is passed in params" do
      child2 = Child.new(:title => 'Child2', :dummy_id => dummy.id)
      child2.dummy.should be_a(Amfetamine::Relationship)
    end

    it "should be possible list all children" do
      dummy.children.should include(child)
      Dummy.cache.flush
      dummy.children.should include(child)
    end

    it "should be possible to get all children if not in memory" do
      Dummy.cache.flush
      new_dummy = nil
      stub_single_response(dummy) do
        new_dummy = Dummy.find(dummy.id)
      end
        
      children = nil
      stub_nested_all_response(dummy,child) do
        children = new_dummy.children.all
      end
      children.should include(child)
    end

    it "should be possible to get a single child if not in memory" do
      child.attributes[:dummy_id] = dummy.id # Lets fake we saved it.
      Dummy.cache.flush
      new_dummy = nil
      stub_single_response(dummy) do
        new_dummy = Dummy.find(dummy.id)
      end

      new_child = nil
      stub_nested_single_response(dummy,child) do
        new_child = new_dummy.children.find(child.id)
      end

      new_child.should == child
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
      puts new_child.inspect

      new_child.should_not be_new
      new_child.should be_cached
      dummy.children.should include(new_child)
      Dummy.cache.flush
      dummy.children.should include(new_child)
    end
  end
end


