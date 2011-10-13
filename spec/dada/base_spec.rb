require 'spec_helper'

# Integration tests :)
describe Dada::Base do
  before(:each) do
    Dummy.resource_suffix = ''
  end

  describe "Dummy, our ever faitful test subject" do
    # Some hight level tests, due to the complexity this makes it a lot easier to refactor
    let(:dummy) { build(:dummy) }
    subject { dummy }

    it { should be_valid }
    its(:title) { should ==('Dummy')}
    its(:description) { should ==('Crash me!')}
    its(:to_json) { should match(/dummy/) }

  end

  describe "Class dummy, setup with dada::base" do
    let(:dummy) { build(:dummy) }
    let(:dummy2) { build(:dummy) }
    subject { Dummy}

    it { should be_cacheable }

    context "#find" do
      it "should find dummy" do
        dummy.instance_variable_set('@notsaved', false)
        stub_single_response(dummy) do
          Dummy.find(dummy.id).should == dummy
        end
        dummy.should be_cached
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
        new_dummy.should be_cached
      end

      it "should return errors if data is incorrect" do
        new_dummy = nil
        stub_post_errornous_response do
          new_dummy = Dummy.create({:title => 'test'})
        end
        new_dummy.should be_new
        new_dummy.errors.messages.should eq({:description => ['can\'t be blank']})
        new_dummy.should_not be_cached
      end
    end

    context "#update" do
      before(:each) do
        dummy.send(:notsaved=, false)
      end

      it "should update if response is succesful" do
        stub_update_response do
          dummy.update({:title => 'zomg'})
        end
        dummy.should_not be_new
        dummy.title.should eq('zomg')
        dummy.should be_cached
      end

      it "should show errors if response is not succesful" do
        stub_update_errornous_response do
          dummy.update({:title => ''})
        end
        dummy.should_not be_new
        dummy.errors.messages.should eq({:title => ['can\'t be blank']})
      end

      it "should not do a request if the data doesn't change" do
        # Assumes that dummy.update would raise if not within stubbed request.
        dummy.update({:title => dummy.title})
        dummy.errors.should be_empty
      end
    end

    context "#delete" do
      before(:each) do
        dummy.send(:notsaved=, false)
      end

      it "should delete the object if response is succesful" do
        stub_delete_response do
          dummy.destroy
        end
        dummy.should be_new
        dummy.id.should be_nil
        dummy.should_not be_cached
      end

      it "should return false if delete failed" do
        stub_delete_errornous_response do
          dummy.destroy
        end
        dummy.should_not be_new
        dummy.errors.messages.should == { :delete => ['Something wen\'t wrong'] }
      end
    end
  end
end