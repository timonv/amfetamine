require 'spec_helper'

# Integration tests :)
describe Dada::Base do
  describe "Dummy, our ever faitful test subject" do
    # Some hight level tests, due to the complexity this makes it a lot easier to refactor
    let(:dummy) { build(:dummy) }
    subject { dummy }

    it { should be_valid }
    it { should be_cached }
    its(:title) { should ==('Dummy')}
    its(:description) { should ==('Crash me!')}
    its(:save) {should be_true}

  end

  describe "Class dummy, setup with dada::base" do
    let(:dummy) { build(:dummy) }
    subject { Dummy}

    it { should be_cachable }

    it "should find dummy" do
      stub_response(dummy) do
        Dummy.find(dummy.id).should == dummy
      end
    end
    
    it "should return nil if object not found" do
      stub_nil_response do
        Dummy.find(dummy.id * 2).should be_nil
      end
    end
  end
end