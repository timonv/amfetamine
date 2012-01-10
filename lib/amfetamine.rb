require "amfetamine/version"
require "amfetamine/helpers/test_helpers" # Testing helper methods
require "amfetamine/exceptions"
require "amfetamine/logger"
require 'amfetamine/relationship'
require "amfetamine/relationships"
require "amfetamine/caching_adapter" # Adapter that wraps memcache methods
require "amfetamine/cache" # Common caching methods
require "amfetamine/rest_helpers" # Methods for determining REST paths
require "amfetamine/query_methods" # Methods for interfacing with the classs
require "amfetamine/base" # Basics
require "amfetamine/config" # Configuration class

module Amfetamine

  def self.logger
    Amfetamine::Logger.instance
  end
end
