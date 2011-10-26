class Child < Dada::Base
  @@children = [] # unrelated to relationships!
  attr_accessor :title, :description, :dummy_id

  belongs_to_resource :dummy

  def initialize(args={})
    @@children << self
    super(args)
  end

  def self.children
    @@children ||= []
  end


  def to_hash
    {
      :title => title,
      :description => description,
      :dummy_id => dummy_id,
      :id => id
    }
  end
end
