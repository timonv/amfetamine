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

  end

  describe "Class dummy, setup with dada::base" do
    let(:dummy) { build(:dummy) }
    let(:dummy2) { build(:dummy) }
    subject { Dummy}

    it { should be_cachable }

    context "#find" do
      it "should find dummy" do
        dummy.instance_variable_set('@notsaved', false)
        stub_single_response(dummy) do
          Dummy.find(dummy.id).should == dummy
        end
      end
      
      it "should return nil if object not found" do
        stub_nil_response do
          Dummy.find(dummy.id * 2).should be_nil
        end
      end
    end

    context "#all" do
      it "should find all if objects are present" do
        dummies = []
        dummy.instance_variable_set('@notsaved', false)
        dummy2.instance_variable_set('@notsaved', false)

        stub_all_response(dummy, dummy2) do
          dummies = Dummy.all
        end

        dummies.should include(dummy)
        dummies.should include(dummy2)
        dummies.length.should eq(2)
      end
      
      it "should return empty array if objects are not present" do
        dummies = []
        stub_all_nil_response do
          dummies = Dummy.all
        end

        dummies.should eq([])
      end
    end

    context "#create" do
      it "should create an object if data is correct" do
        new_dummy = nil
        stub_post_response do
          new_dummy = Dummy.create({:title => 'test', :description => 'blabla'})
        end
        new_dummy.should be_a(Dummy)
        new_dummy.should_not be_new
      end

      it "should return errors if data is incorrect" do
        new_dummy = nil
        stub_post_errornous_response do
          new_dummy = Dummy.create({:title => 'test'})
        end
        new_dummy.should be_new
        new_dummy.errors.should eq({'description' => 'can\'t be empty'})
      end
    end
  end
end