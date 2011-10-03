module Dada
  class Base
    include Dada::RestHelpers

    attr_accessor :title, :description, :id

    # Base method for finding objects
    # Should this be refactored to a different class that checks if cached and returns object?
    def self.find(id)
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

    # Builds an object from JSON, later on will need more (maybe object id? Or should that go in find?)
    # For now, we return the same object if its still in process memory
    def self.build_object(args)
      args = args[self.name.downcase]
      self.new(args)
    end

    # Base method for creating objects
    # TODO implement
    def initialize(args)
      args.each { |k,v| public_send("#{k}=", v) }
    end


    # Checks if object is cached
    # TODO implement
    def cached?
      true
    end

    # Checks if object is cachable
    # TODO implement
    def self.cachable?
      true
    end

    # Saves an object and writes it off to server (by delegation)
    # TODO implement
    def save
      true
    end

    # Checks to see if an object is valid or not
    # TODO implement
    def valid?
      true
    end

    # We need to redefine this so it doesn't check on object_id
    def ==(other)
      self.instance_variables.all? do |i|
        self.instance_variable_get(i) == other.instance_variable_get(i)
      end
    end


  end
end
