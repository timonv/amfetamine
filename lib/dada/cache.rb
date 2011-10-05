require "dalli"

module Dada
  class Cache
    class << self
      def get(key)
        Dada::Config.memcached_instance.get(key)
      end

      def add(key, data)
        Dada::Config.memcached_instance.add(key,data)
      end

      def delete(key)
        Dada::Config.memcached_instance.delete(key)
      end
    end
  end
end
