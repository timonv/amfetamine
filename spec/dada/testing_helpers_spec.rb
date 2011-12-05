require 'spec_helper'

describe "test_helpers" do
  describe "#prevent_external_connections!" do
    it "should raise exception if connections are tried to be made" do
      Dummy.prevent_external_connections!
      lambda { Dummy.all }.should raise_exception(Dada::ExternalConnectionsNotAllowed)
    end

    it "should return correct objects if responses are stubbed for #singular" do
      Dummy.prevent_external_connections!
      dummy = build(:dummy)

      Dummy.stub_responses! do
        get { dummy  }
      end

      Dummy.find(dummy.id).should == dummy
    end

    it "should return correct objects if responses are stubbed for #all" do
      dummy = build(:dummy)

      Dummy.stub_responses! do
        get { [dummy] }
      end

      Dummy.all.should == [dummy]
    end

    it "should return give me correct response codes" do
      Dummy.stub_responses! do
        post(201) { }
      end

      dummy = Dummy.new(title: 'valid', description: 'valid')
      dummy.valid?.should be_true
      dummy.save.should be_true
    end
  end
end
