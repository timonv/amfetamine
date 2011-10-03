require 'spec_helper'

describe Dada::RestHelpers do
  context "methods" do
    describe "plural_path" do
      Dummy.rest_path.should ==('/dummies')
    end

    describe "singular_path" do
      dummy = build(:dummy)
      dummy.singular_path.should ==("/dummies/#{dummy.id}")
    end

    describe "find_path" do
      dummy = build(:dummy)
      Dummy.find_path(dummy.id).should ==("/dummies/#{dummy.id}")
    end
  end
end
