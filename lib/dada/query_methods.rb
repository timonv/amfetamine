module Dada
  module QueryMethods
 # Base method for finding objects
    # Should this be refactored to a different class that checks if cached and returns object?
    def self.included(base)
      base.extend ClassMethods
    end

    # Can't set new? as an instance var
    module ClassMethods
      def find(id)
        key = self.find_path(id)
        if data = Dada::Cache.get(key) && cachable?
          return build_object(data)
        elsif data = self.handle_request(:get, key)
          Dada::Cache.add(key, data) if cachable?
          return build_object(data)
        else
          return nil
        end
      end

      def all
        key = self.rest_path
        if data = Dada::Cache.get(key) && cachable?
          return data.map { |d| build_object(d) }
        elsif data = self.handle_request(:get, key)
          Dada::Cache.add(key, data) if cachable?
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

      if self.new?
        response = self.class.handle_request(:post, self.rest_path, self.to_json)
      else
        response = self.class.handle_request(:put, self.singular_path, self.to_json)
      end
      handle_response(response)
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
