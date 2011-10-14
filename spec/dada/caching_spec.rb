require 'spec_helper'

describe Dada::Cache do
  it "should return same data after all request has been made" do
    dummy = build(:dummy)
    dummy2 = build(:dummy)
    dummies = nil
    stub_all_response(dummy, dummy2) do
      dummies = Dummy.all
    end
    dummies_no_request = Dummy.all
    dummies.should == dummies
  end

  it "should return same data after find request has been made" do
    dummy = build(:dummy)
    return_dummy = nil
    stub_single_response(dummy) do
      return_dummy = Dummy.find(dummy.id) 
    end
    dummy_no_request = Dummy.find(dummy.id)
    dummy_no_request.should == return_dummy
  end

  it "should update the cache after a save has been made" do
    dummy = build(:dummy)
    dummy.instance_variable_set('@notsaved', false)
    dummy.title = 'blabla'
    stub_update_response(dummy) do
      dummy.save
    end
    dummy2 = Dummy.find(dummy.id)
    dummy2.should == dummy
  end

end

