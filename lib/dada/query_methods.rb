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
          data = get_data(key)
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

      def create(args)
        self.new(args).tap(&:save)
      end

      def get_data(key, method=:get)
        if cacheable?
          cache.fetch(key) do
            handle_request(method, key)
          end
        else
          handle_request(method,key)
        end
      end
    end

    def save
      if !valid?
        return false
      end

      response = if self.new?
        self.class.handle_request(:post, rest_path, self.to_json)
      else
        self.class.handle_request(:put, singular_path, self.to_json)
      end

      if handle_response(response)
        begin
          update_attributes_from_response(response[:body])
          cache.delete(rest_path) if cacheable?
          cache.set(singular_path, self.to_cacheable) if cacheable?
        rescue
          cache.delete(singular_path)
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
        cache.delete(singular_path) if cacheable?
        cache.delete(rest_path) if cacheable?
        self.notsaved = true # Because its a new object if the server side got deleted
        self.id = nil # Not saved? No ID.
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
