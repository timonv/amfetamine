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
        post(code: 201) { }
      end

      dummy = Dummy.new(title: 'valid', description: 'valid')
      dummy.valid?.should be_true
      dummy.save.should be_true
    end

    it "should also work with multiple paths" do
      dummy = build(:dummy)

      Dummy.stub_responses! do
        get(code: 200, path: '/dummies/1') { dummy }
        get(code: 200, path: '/dummies/') { [ dummy ] }
      end

      Dummy.find(1).should == dummy
      Dummy.all.should == [dummy]
    end
  end
end
