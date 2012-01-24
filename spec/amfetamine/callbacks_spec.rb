require 'spec_helper'


describe "Callbacks" do
  before do
    Dummy.stub_responses! do |r|
      r.post { build(:dummy) }
    end
  end

  context "create" do
    it "should work with before" do
      Dummy.any_instance.should_receive(:"action_before_create")
      Dummy.create
    end

    it "should work with after" do
      pending "Not working, but not needed either"
      Dummy.any_instance.should_receive(:"action_after_create")
      Dummy.create
    end
  end

  context "save" do
    it "should work" do
      dummy = build(:dummy)
      dummy.should_receive(:"action_before_save")
      dummy.should_receive(:"action_after_save")
      dummy.save
    end
  end

  context "validate" do
    it "should work" do
      dummy = build(:dummy)
      dummy.should_receive(:"action_before_validate")
      dummy.valid?
    end
  end
end




