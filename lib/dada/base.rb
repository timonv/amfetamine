module Dada
  class Base
    include Dada::RestHelpers
    include Dada::QueryMethods

    attr_reader :id

   
    # Builds an object from JSON, later on will need more (maybe object id? Or should that go in find?)
    # It parses the hash, builds the objects and sets new to false
    def self.build_object(args)
      args = args[self.name.downcase]
      obj = self.new(args)
      obj.tap { |obj| obj.instance_variable_set('@notsaved',false) } # because I don't want a global writer
    end

    # Base method for creating objects
    # TODO implement
    def initialize(args)
      self.id = args.delete(:id) || args.delete('id')
      args.each { |k,v| self.public_send("#{k}=", v) }
      @notsaved = true
      self
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

    def errors
      @errors ||= {}
    end

    protected
    def self.cache
      @cache_server || Dada::Cache
    end
  end
end
