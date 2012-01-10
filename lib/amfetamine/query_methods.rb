require 'active_support/core_ext' # For to_query

module Amfetamine
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
          data = get_data(key, opts[:conditions])
          if data[:status] == :success
            build_object(data[:body]) 
          else
            nil
          end
        rescue
          clean_cache!
          raise
        end
      end

      def all(opts={})
        begin
          key = opts[:nested_path] || self.rest_path
          data = get_data(key, opts[:conditions])

          if data[:status] == :success
            data[:body].compact.map { |d| build_object(d) }
          else
            []
          end
        rescue
          clean_cache!
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
        self.new(args).tap do |obj|
          obj.run_callbacks(:create) { obj.save }
        end
      end

      def get_data(key, conditions=nil, method=:get)
        if cacheable?
          if conditions
            cache_key = key + conditions.to_query
            cache_conditions(key, conditions)
          else
            cache_key = key
          end

          Amfetamine.logger.info "Fetching object from cache: #{cache_key}"
          cache.fetch(cache_key) do
            Amfetamine.logger.info "Miss! #{cache_key}"
            handle_request(method, key, { :query => conditions } )
          end
        else
          handle_request(method,key, { :query => conditions })
        end
      end

      def clean_cache!
        if cacheable?
          cache.delete(rest_path)
          condition_keys = cache.get("#{rest_path}_conditions") || []
          condition_keys.each do |cc|
            cache.delete(rest_path + cc)
          end
          Amfetamine.logger.info "Cleaned cache for #{self.model_name}"
        end
      end
    end

    def save
      if !valid?
        return false
      end

      run_callbacks(:save) do
        response = if self.new?
                     path = self.belongs_to_relationship? ? belongs_to_relationships.first.rest_path : rest_path
                     self.class.handle_request(:post, path, {:body => self.to_json })
                   else
                     # Needs cleaning up, also needs to work with multiple belongs_to relationships (optional, I guess)
                     path = self.belongs_to_relationship? ? belongs_to_relationships.first.singular_path : singular_path
                     self.class.handle_request(:put, path, {:body => self.to_json})
                   end

        if handle_response(response)
          begin
            update_attributes_from_response(response[:body])
          ensure
            clean_cache!
          end
          cache.set(singular_path, self.to_cacheable) if cacheable?
        end
      end
    end

    def destroy
      if self.new?
        return false
      end

      path = self.belongs_to_relationship? ? belongs_to_relationships.first.singular_path : singular_path
      response = self.class.handle_request(:delete, path)

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
        Amfetamine.logger.info "Cleaned cache for #{self.class_name} with ID #{self.id}"
      end
    end




    def update_attributes(attrs)
      return true if attrs.all? { |k,v| self.send(k) == v } # Don't update if no attributes change
      attrs.each { |k,v| self.send("#{k}=", v) }
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
