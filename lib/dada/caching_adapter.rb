module Dada
  # This adapter wraps methods around memcached (dalli) methods
  module CachingAdapter
    def self.included(base)
      base.extend ClassAndInstanceMethods
      base.extend CacheServer
      base.send(:include,ClassAndInstanceMethods)
    end


    def initialize(server, options={})
      @cache_server ||= Dalli::Client.new(server, options)
    end

    def cache_server
      @cache_server
    end

    private :cache_server

    module ClassAndInstanceMethods
      def get(key)
        cache_server.get(key)
      end

      def set(key,data)
        cache_server.set(key, data)
      end

      def add(key, data)
        cache_server.add(key,data)
      end

      def delete(key)
        cache_server.delete(key)
      end

      def flush
        cache_server.flush
      end
    end

    module CacheServer
      private
      def cache_server
        Dada::Config.memcached_instance
      end

  

    end
  end
end

