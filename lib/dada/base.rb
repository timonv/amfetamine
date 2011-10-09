require 'active_model'

module Dada
  class Base
    include Dada::RestHelpers
    include Dada::QueryMethods

    # Activemodel
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serialization

    attr_reader :id

   
    # Builds an object from JSON, later on will need more (maybe object id? Or should that go in find?)
    # It parses the hash, builds the objects and sets new to false
    def self.build_object(args)
      args = args[self.name.downcase]
      obj = self.new(args)
      obj.tap { |obj| obj.instance_variable_set('@notsaved',false) } # because I don't want a global writer
    end

    # Allows you to override the global caching server
    def self.memcached_instance(value, options={})
      @cache_server = Dada::Cache.new(value, options)
    end

    # Base method for creating objects
    def initialize(args={})
      self.id = args.delete(:id) || args.delete('id')
      args.each { |k,v| self.public_send("#{k}=", v) }
      @notsaved = true
      self
    end

    def persisted?
      !new?
    end

    def to_model
      self
    end

    def to_key
      persisted? ? [id] : nil
    end

    def to_param
      persisted? ? id.to_s : nil
    end


    # Checks if object is cached
    # TODO this is not very efficient, but dalli doesn't provide a polling function :(
    def cached?
      self.cache.get(self.singular_path) ? true : false
    end

    # Checks if object is cachable
    # TODO implement
    def self.cachable?
      true
    end

    # Checks to see if an object is valid or not
    # TODO implement
    def valid?
      errors.clear
      run_validations!
    end

    # We need to redefine this so it doesn't check on object_id
    def ==(other)
      self.instance_variables.all? do |i|
        self.instance_variable_get(i) == other.instance_variable_get(i)
      end
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    protected
    def self.cache
      @cache_server || Dada::Cache
    end

    def cache
      self.class.cache
    end

  end
end
