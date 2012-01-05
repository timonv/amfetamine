require 'spec_helper'

describe Dummy do
  context "ActiveModel Lint test" do
    subject { Dummy.new }
    it_should_behave_like "ActiveModel"
  end

  context "Client side validation" do
    let(:dummy) { Dummy.new }

    it "should not be valid" do
      dummy.should_not be_valid
    end
  end

  context "Configuration" do
    it "should be configurable" do
      Dummy.dada_configure :memcached_instance => ['localhost:11211', {:key => 1}], :rest_client => DummyRestClient, :resource_suffix => '.json'
      cs = Dummy.instance_variable_get('@cache_server')
      cs.should be_a(Dada::Cache)
      cs.instance_variable_get('@cache_server').instance_variable_get('@options').should include(:key => 1) # Annoying bug :/
      Dummy.rest_client.should == DummyRestClient
      Dummy.resource_suffix.should == '.json'
    end
  end
end
