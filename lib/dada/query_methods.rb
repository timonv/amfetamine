module Dada
  module QueryMethods
    # Base method for finding objects
    # Should this be refactored to a different class that checks if cached and returns object?
    # Caching methods are called here ONLY.
    def self.included(base)
      base.extend ClassMethods
    end

    # Can't set new? as an instance var
    module ClassMethods
      def find(id)
        key = self.find_path(id)
        if data = self.cache.get(key) && cachable?
          return build_object(data)
        elsif data = self.handle_request(:get, key)
          self.cache.add(key, data) if cachable?
          return build_object(data)
        else
          return nil
        end
      end

      def all
        key = self.rest_path
        if data = self.cache.get(key) && cachable?
          return data.map { |d| build_object(d) }
        elsif data = self.handle_request(:get, key)
          self.cache.add(key, data) if cachable?
          return data.map { |d| build_object(d) }
        else
          return nil
        end
      end

      def create(args)
        self.new(args).tap(&:save)
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
        cache.set(singular_path, self.to_json)
      end
    end

    def destroy
      if self.new?
        return false
      end

      response = self.class.handle_request(:delete, singular_path)

      if handle_response(response)
        cache.delete(singular_path)
        self.notsaved = true # Because its a new object if the server side got deleted
        self.id = nil # Not saved? No ID.
      end
    end

    def update(attrs)
      return true if attrs.all? { |k,v| self.public_send(k) == v } # Don't update if no attributes change
      attrs.each { |k,v| self.public_send("#{k}=", v) }
      self.save
    end


    def new?
      @notsaved
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
