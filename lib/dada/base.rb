require 'active_model'

module Dada
  class Base
    include Dada::RestHelpers
    include Dada::QueryMethods
    include Dada::Relationships

    # Activemodel
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON

    attr_reader :id
    attr_accessor :attributes

   
    # Builds an object from JSON, later on will need more (maybe object id? Or should that go in find?)
    # It parses the hash, builds the objects and sets new to false
    def self.build_object(args)
      # Cache corruption guard
      args = normalize_cache_data(args)

      obj = self.new(args)
      obj.tap { |obj| obj.instance_variable_set('@notsaved',false) } # because I don't want a global writer
    end

    def update_attributes_from_response(args)
      # We need to check this. If an api provides new data after an update, it will be set :-)
      # Some apis return "nil" or something like that, so we need to double check its a hash
      if args && args.is_a?(Hash) && args.has_key?(self.class_name)
        args = args[self.class_name]
        args.each { |k,v| self.send("#{k}=", v); self.attributes[k.to_sym] = v  }
      end
    end

    # Allows you to override the global caching server
    def self.memcached_instance=(value, options={})
      if value.is_a?(Array)
        @cache_server = Dada::Cache.new(value.shift, value.first) # First element is the server, second must be the options
      else
        @cache_server = Dada::Cache.new(value, options)
      end
    end

    # Base method for creating objects
    def initialize(args={})
      super
      @attributes = {}

      args.each { |k,v| self.send("#{k}=", v); self.attributes[k.to_sym] = v  }
      @notsaved = true
      self
    end

    def is_attribute?(attr)
      attributes.has_key?(attr.to_sym)
    end

    def persisted?
      !new?
    end

    def to_model
      self
    end

    def to_json(*gen)
      options = {}
      options.merge!(:root => self.class.model_name.element)
      super(self.as_json(options))
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
      keys = belongs_to_relationships.collect { |r| r.singular_path } << self.singular_path
      keys.any? { |k| cache.get(k) }
    end

    # Checks if object is cachable
    # TODO implement
    def self.cacheable?
      true
    end

    def cacheable?
      self.class.cacheable?
    end

    # Checks to see if an object is valid or not
    def valid?
      errors.clear
      run_validations!
    end

    # We need to redefine this so it doesn't check on object_id
    def ==(other)
      self.attributes.all? do |k,v|
        self.attributes[k] == other.attributes[k]
      end
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def self.configure_dada(hash)
      hash.each do |k,v|
        self.public_send("#{k.to_s}=", v)
      end
    end

    def class_name
      self.class.class_name
    end

    def self.class_name
      self.name.downcase
    end

    protected
    def self.cache
      @cache_server || Dada::Cache
    end

    def cache
      self.class.cache
    end

    def self.normalize_cache_data(args)
      # Validation predicates
      raise InvalidCacheData, "Empty data" if args.nil?
      args.stringify_keys!
      args = args[class_name]
      # TODO remove [:id], stringify_keys! _should_ nail this.
      raise InvalidCacheData, "No object or ID #{args}"  unless args.present? && (args["id"] || args[:id])
      args
    end
  end
end
