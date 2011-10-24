require_relative 'configure.rb'
require 'json'

class Dummy < Dada::Base
  @@children = [] # unrelated to relationships!

  attr_accessor :title, :description
  validates_presence_of :title, :description

  has_many_resources :children

  def to_hash
    {
      :title => title,
      :description => description,
      :id => id
    }
  end


  # Needed for proper ID tracking
  def initialize(args={})
    @@children << self
    super(args)
  end

  def self.children
    @@children ||= []
  end

end
