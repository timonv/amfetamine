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
      other.send("#{from_singular_name}_id=", @from.id)
      other.instance_variable_set("@#{from_singular_name}", Dada::Relationship.new(:on => @from, :from => other, :type => :belongs_to))
      @children << other
    end

    def on_class
      if @on.is_a?(Symbol)
        Dada.parent.const_get(@on.to_s.gsub('/', '::').singularize.gsub('_','').capitalize)
      else
        @on.class
      end
    end

    # Id of object this relationship references
    def parent_id
      if @on.is_a?(Symbol)
        @from.send(@on.to_s.downcase + "_id") if @type == :belongs_to
      else
        @on.id
      end
    end

    # Id of the receiving object
    def from_id
      @from.id
    end

    def from_plural_name
      @from.class.name.to_s.downcase.pluralize
    end

    def from_singular_name
      @from.class.name.to_s.downcase
    end

    def on_plural_name
      if @on.is_a?(Symbol)
        @on.to_s.pluralize
      else
        @on.class.name.to_s.pluralize.downcase
      end
    end

    def rest_path
      on_class.rest_path(:relationship => self)
    end

    def find_path(id)
      on_class.find_path(id, :relationship => self)
    end

    def singular_path
      find_path(@from.id)
    end

    def full_path
      if @type == :has_many
        "#{from_plural_name}/#{from_id}/#{on_plural_name}"
      elsif @type == :belongs_to
        "#{on_plural_name}/#{parent_id}/#{from_plural_name}"
      end
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
