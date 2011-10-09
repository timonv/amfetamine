require 'spec_helper'

describe Dummy do
  context "ActiveModel Lint test" do
    subject { Dummy.new }
    it_should_behave_like "ActiveModel"
  end

  context "Client side validation" do
    let(:dummy) { Dummy.new }

    it "should not be valid" do
      puts dummy.title
      puts dummy.description
      dummy.should_not be_valid
    end

    it "should have correct error messages" do
      puts subject.errors.full_messages
    end
  end
end
