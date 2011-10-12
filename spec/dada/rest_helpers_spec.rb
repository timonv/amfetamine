require 'spec_helper'

describe Dada::RestHelpers do
  context "methods" do
    before(:each) do
      # Needed because rspec caches classes across runs (thank god it does)
      Dummy.resource_suffix = ''
    end

    it "plural_path" do
      Dummy.rest_path.should ==('/dummies')
    end

    it "singular_path" do
      dummy = build(:dummy)
      dummy.singular_path.should ==("/dummies/#{dummy.id}")
    end

    it "find_path" do
      dummy = build(:dummy)
      Dummy.find_path(dummy.id).should ==("/dummies/#{dummy.id}")
    end

    it "should work with a resource suffix" do
      Dummy.resource_suffix = '.json'
      Dummy.rest_path.should ==('/dummies.json')
    end
  end
end
