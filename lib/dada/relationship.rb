module Dada
  class Relationship
    include Enumerable

    attr_reader :on, :type, :from

    def initialize(opts)
      @type = opts[:type]
      @on = opts[:on] # Target class
      @from = opts[:from] # receiving object
      @children = []
    end

    def << (other)
      other.send("#{@from.class.name.downcase}_id=", @from.id)
      @children << other
    end

    def on_class
      Dada.parent.const_get(@on.to_s.gsub('/', '::').singularize.gsub('_','').capitalize)
    end

    # Id of object this relationship references
    def parent_id
      @from.send(@on.to_s.downcase + "_id") if @type == :belongs_to
    end

    # Id of the receiving object
    def from_id
      @from.id
    end

    def from_plural_name
      @from.class.name.to_s.downcase.pluralize
    end

    def on_plural_name
      @on.to_s
    end

    def rest_path
      on_class.rest_path(:relationship => self)
    end

    def find_path(id)
      on_class.find_path(id, :relationship => self)
    end

    def full_path
      "#{from_plural_name}/#{from_id}/#{on_plural_name}"
    end

    def each
      @children.each { |c| yield c }
    end

    # Delegates the all method to child class with a nested path set
    def all(opts={})
      @children = on_class.all({ :nested_path => rest_path }.merge(opts))
    end

    # Delegates the find method to child class with a nested path set
    def find(id, opts={})
      on_class.find(id, {:nested_path => find_path(id)}.merge(opts))
    end


    def include?(other)
      @children.include?(other)
    end

  end
end
