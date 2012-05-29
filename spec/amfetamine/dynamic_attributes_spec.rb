require 'spec_helper'

# Let's create a new class for our experiments
class Dummy2 < Amfetamine::Base
  def initialize(args={})
    @@children << self
    super(args)
  end

  def self.children
    @@children ||= []
  end
end

describe "Dynamic Attributes" do
  let(:dummy) {build(:dummy2)}

  it "should set attributes dynamically" do
    Dummy2.prevent_external_connections! do |r|
      r.get {dummy}
      dummy.should respond_to(:title=)
      dummy.should respond_to(:title)
      dummy.should respond_to(:description=)
      dummy.should respond_to(:description)
    end
  end
end

