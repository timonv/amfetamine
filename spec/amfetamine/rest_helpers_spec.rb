require 'spec_helper'

describe Amfetamine::RestHelpers do
  context "methods" do

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
