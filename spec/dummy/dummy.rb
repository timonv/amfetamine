require_relative 'configure.rb'
require 'json'

class Dummy < Dada::Base
  def to_hash
    {
      :title => title,
      :description => description,
      :id => id
    }
  end
end
