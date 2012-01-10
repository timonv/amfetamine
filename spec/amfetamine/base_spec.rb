require 'spec_helper'

# Integration tests :)
describe Amfetamine::Base do
  describe "Dummy, our ever faitful test subject" do
    # Some hight level tests, due to the complexity this makes it a lot easier to refactor
    let(:dummy) { build(:dummy) }
    subject { dummy }

    it { should be_valid }
    its(:title) { should ==('Dummy')}
    its(:description) { should ==('Crash me!')}
    its(:to_json) { should match(/dummy/) }

  end

  describe "Class dummy, setup with amfetamine::base" do
    let(:dummy) { build(:dummy) }
    let(:dummy2) { build(:dummy) }
    subject { Dummy}

    it { should be_cacheable }

    context "#attributes" do
      it "should update attribute correctly if I edit it" do
        dummy.title = "Oh a new title!"
        dummy.attributes['title'].should == "Oh a new title!"
      end

      it "should include attributes in json" do
        dummy.title = "Something new"
        dummy.to_json.should match(/Something new/)
      end
    end

    context "#find" do
      it "should find dummy" do
        dummy.instance_variable_set('@notsaved', false)
        stub_single_response(dummy) do
          Dummy.find(dummy.id).should == dummy
        end
        dummy.should be_cached
      end
      
      it "should return nil if object not found" do
        lambda {
        stub_nil_response do
          Dummy.find(dummy.id * 2).should be_nil
        end
        }.should raise_exception(Amfetamine::RecordNotFound)
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
          dummy.update_attributes({:title => 'zomg'})
        end
        dummy.should_not be_new
        dummy.title.should eq('zomg')
        dummy.should be_cached
      end

      it "should show errors if response is not succesful" do
        stub_update_errornous_response do
          dummy.update_attributes({:title => ''})
        end
        dummy.should_not be_new
        dummy.errors.messages.should eq({:title => ['can\'t be blank']})
      end

      it "should not do a request if the data doesn't change" do
        # Assumes that dummy.update would raise if not within stubbed request.
        dummy.update_attributes({:title => dummy.title})
        dummy.errors.should be_empty
      end
    end

    context "#save" do
      before(:each) do
        dummy.send(:notsaved=, true)
      end

      it "should update the id if data is received from post" do
        old_id = dummy.id
        stub_post_response(dummy) do
          dummy.send(:id=, nil)
          dummy.save
        end
        dummy.id.should == old_id
        dummy.attributes[:id].should == old_id
      end

      it "should update attributes if data is received from update" do
        dummy.send(:notsaved=, false)
        old_id = dummy.id
        dummy.title = "BLABLABLA"
        stub_update_response(dummy) do
          dummy.title = "BLABLABLA"
          dummy.save
        end
        dummy.id.should == old_id
        dummy.title.should == "BLABLABLA"
        dummy.attributes[:title] = "BLABLABLA"
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
        dummy.should_not be_cached
      end
    end
  end

  describe "Features and bugs" do
    it "should raise an exception if cached args are nil" do
      lambda { Dummy.build_object(nil) }.should raise_exception(Amfetamine::InvalidCacheData)
    end

    it "should raise an exception if cached args do not contain an ID" do
      lambda { Dummy.build_object(:no_id => 'present') }.should raise_exception(Amfetamine::InvalidCacheData)
    end

    it "should raise correct exception is data is not expected format" do
      lambda { Dummy.build_object([]) }.should raise_exception(Amfetamine::InvalidCacheData)
    end

    it "should receive data when doing a post" do
      Dummy.prevent_external_connections! do
        dummy = build(:dummy)
        Dummy.rest_client.should_receive(:post).with("/dummies", :body => dummy.to_json).
          and_return(Amfetamine::FakeResponse.new('post', 201, lambda { dummy }))
        dummy.save
      end
    end

  end
      
end
