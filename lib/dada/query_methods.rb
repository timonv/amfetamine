require 'active_support/core_ext' # For to_query

module Dada
  module QueryMethods
    # Base method for finding objects
    # Should this be refactored to a different class that checks if cached and returns object?
    # Caching methods are called here ONLY.
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find(id, opts={})
        begin
          key = opts[:nested_path] || self.find_path(id)
          data = get_data(key)
          if data[:status] == :success
            build_object(data[:body]) 
          else
            nil
          end
        rescue
          cache.delete(key)
          raise
        end
      end

      def all(opts={})
        begin
          key = opts[:nested_path] || self.rest_path
          data = get_data(key, opts[:conditions])

          if data[:status] == :success
            data[:body].map { |d| build_object(d) }
          else
            []
          end
        rescue
          cache.delete(key)
          raise
        end
      end

      def cache_conditions(key, condition=nil)
        return nil unless condition
        conditions = cache.get("#{key}_conditions") || []
        q_condition = condition.to_query

        if !conditions.include?(q_condition)
          conditions << condition.to_query
          cache.set("#{key}_conditions", conditions)
        end
      end

      def create(args={})
        self.new(args).tap(&:save)
      end

      def get_data(key, conditions=nil, method=:get)
        if cacheable?
          if conditions
            cache_key = key + conditions.to_query
            cache_conditions(key, conditions)
          else
            cache_key = key
          end

          cache.fetch(cache_key) do
            handle_request(method, key, { :query => conditions } )
          end
        else
          handle_request(method,key, { :query => conditions })
        end
      end
    end

    def save
      if !valid?
        return false
      end

      response = if self.new?
        self.class.handle_request(:post, rest_path, {:body => self.to_json })
      else
        self.class.handle_request(:put, singular_path, {:body => self.to_json})
      end

      if handle_response(response)
        begin
          update_attributes_from_response(response[:body])
          clean_cache!
          cache.set(singular_path, self.to_cacheable) if cacheable?
        rescue
          clean_cache!
          raise
        end
      end
    end

    def destroy
      if self.new?
        return false
      end

      response = self.class.handle_request(:delete, singular_path)

      if handle_response(response)
        clean_cache!
        self.notsaved = true # Because its a new object if the server side got deleted
        self.id = nil # Not saved? No ID.
      end
    end

    def clean_cache!
      if cacheable?
        cache.delete(singular_path)
        cache.delete(rest_path)
        belongs_to_relationships.each do |r|
          cache.delete(r.singular_path)
          cache.delete(r.rest_path)
          condition_keys = cache.get("#{r.rest_path}_conditions") || []
          condition_keys.each do |cc|
            cache.delete(r.rest_path + cc)
          end
        end
        
        condition_keys = cache.get("#{rest_path}_conditions") || []
        condition_keys.each do |cc|
          cache.delete(rest_path + cc)
        end
      end
    end

    def update_attributes(attrs)
      return true if attrs.all? { |k,v| self.public_send(k) == v } # Don't update if no attributes change
      attrs.each { |k,v| self.public_send("#{k}=", v) }
      self.save
    end


    def new?
      @notsaved
    end

    def to_cacheable
      {
        :status => :success,
        :body => {
          self.class.name.downcase.to_sym => self.attributes
        }
      }
    end

    private
    def id=(id)
      @id = id
    end
     def notsaved=(bool)
       @notsaved = bool
     end
  end
end
