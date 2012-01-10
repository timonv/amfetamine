require 'spec_helper'

describe "test_helpers" do
  let(:test_dummy) { build(:dummy) }
  describe "#prevent_external_connections!" do
    it "should raise exception if connections are tried to be made" do
      Dummy.prevent_external_connections!
      lambda { Dummy.all }.should raise_exception(Amfetamine::ExternalConnectionsNotAllowed)
    end

    it "should return correct objects if responses are stubbed for #singular" do
      dummy = build(:dummy)

      Dummy.stub_responses! do |res|
        res.get { dummy  }
      end

      Dummy.find(dummy.id).should == dummy
    end

    it "should return correct objects if responses are stubbed for #all" do
      dummy = build(:dummy)

      Dummy.stub_responses! do |res|
        res.get { [dummy] }
      end

      Dummy.all.should == [dummy]
    end

    it "should return give me correct response codes" do
      Dummy.stub_responses! do |res|
        res.post(:code => 201) { }
      end

      dummy = Dummy.new(:title => 'valid', :description => 'valid')
      dummy.valid?.should be_true
      dummy.save.should be_true
    end

    it "should also work with multiple paths" do
      dummy = build(:dummy)

      Dummy.stub_responses! do |res|
        res.get(:code => 200, :path => '/dummies/1') { dummy }
        res.get(:code => 200, :path => '/dummies/') { [ dummy ] }
      end

      Dummy.find(1).should == dummy
      Dummy.all.should == [dummy]
    end


    it "should work with a let statement" do
      lambda {
        Dummy.stub_responses! do |res|
          res.get { test_dummy }
          res.get(:path => '/dummies') { [test_dummy] }
        end
      }.should_not raise_exception
    end

    it "should work with opts parsed and descriminate #all" do
      dummy1 = build(:dummy)
      dummy2 = build(:dummy)

      dummy1.title = "DUMMY1"
      dummy2.title = "DUMMY2"

      Dummy.stub_responses! do |r|
        r.get(:path => '/dummies', :query => {:title => "DUMMY1"}) { [dummy1] }
        r.get(:path => '/dummies', :query => {:title => "DUMMY2"}) { [dummy2] }
      end

      Dummy.all(:conditions => {:title => "DUMMY1"}).should include(dummy1)
      Dummy.all(:conditions => {:title => "DUMMY1"}).should_not include(dummy2)

      Dummy.all(:conditions => {:title => "DUMMY2"}).should include(dummy2)
      Dummy.all(:conditions => {:title => "DUMMY2"}).should_not include(dummy1)
    end

    it "should work with opts parsed and descriminate #all" do
      dummy1 = build(:dummy)
      dummy2 = build(:dummy)

      dummy1.title = "DUMMY1"
      dummy2.title = "DUMMY2"

      Dummy.stub_responses! do |r|
        r.get(:path => "/dummies/#{dummy1.id}", :query => {:title => "DUMMY1"}) { dummy1 }
        r.get(:path => "/dummies/#{dummy2.id}", :query => {:title => "DUMMY2"}) { dummy2 }
      end

      Dummy.find(dummy1.id, :conditions => {:title => "DUMMY1"}).should ==(dummy1)
      Dummy.find(dummy1.id, :conditions => {:title => "DUMMY1"}).should_not ==(dummy2)

      Dummy.find(dummy2.id, :conditions => {:title => "DUMMY2"}).should ==(dummy2)
      Dummy.find(dummy2.id, :conditions => {:title => "DUMMY2"}).should_not ==(dummy1)
    end
  end
end
