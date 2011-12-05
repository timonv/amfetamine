require "dada/version"
require "dada/helpers/test_helpers" # Testing helper methods
require "dada/exceptions"
require "dada/logger"
require 'dada/relationship'
require "dada/relationships"
require "dada/caching_adapter" # Adapter that wraps memcache methods
require "dada/cache" # Common caching methods
require "dada/rest_helpers" # Methods for determining REST paths
require "dada/query_methods" # Methods for interfacing with the classs
require "dada/base" # Basics
require "dada/config" # Configuration class

module Dada

  def self.logger
    Dada::Logger.instance
  end
end
