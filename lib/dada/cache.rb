require "dalli"

module Dada
  # Class that functions as the general talk-to cache
  # Seperated from adapter functions to decrease method definitions
  class Cache
    include CachingAdapter
  end
end
