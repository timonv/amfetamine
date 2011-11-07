require 'spec_helper'

describe "Dada REST Helpers with conditions" do
  it "should work regular #all" do
    Dummy.cache.flush # Just to be uber sure

    query = {:title => 'Dummy'}
    dummy = build(:dummy)
    dummy.instance_variable_set('@notsaved',false)

    result = nil
    stub_conditional_all_response(dummy, query) do
      result = Dummy.all(:conditions => query)
    end
    result2 = Dummy.all(:conditions => query) # No errors raised means it got it from the cache
    result.should == result2
    result.should include(dummy)
    stub_delete_response do
      dummy.destroy
    end

    lambda {Dummy.all(:conditions => query) }.should raise_exception(FakeWeb::NetConnectNotAllowedError)
  end

  it "should work with nested resource #all" do
    Dummy.cache.flush # Just to be uber sure
    Child.cache.flush

    query = {:title => 'Child'}
    dummy = build(:dummy)
    child = build(:child)
    dummy.children << child

    dummy.instance_variable_set('@notsaved',false)
    child.instance_variable_set('@notsaved',false)

    result = nil
    stub_conditional_nested_all_response(dummy, child, query) do
      result = dummy.children.all(:conditions => query)
    end
    result2 = dummy.children.all(:conditions => query) # No errors raised means it got it from the cache
    result.should == result2
    result.should include(child)
    

    stub_delete_response(child) do
      child.destroy
    end
    
    child.should_not be_cached

    lambda {dummy.children.all(:conditions => query, :force => true) }.should raise_exception(FakeWeb::NetConnectNotAllowedError)
  end
end

