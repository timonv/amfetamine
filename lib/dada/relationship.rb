module Dada
  class Relationship
    include Enumerable

    attr_reader :on, :type, :from

    def initialize(opts)
      @type = opts[:type]
      #@on = Dada.parent.const_get(opts[:on].to_s.gsub('/', '::').singularize.gsub('_','').capitalize)
      @on = opts[:on]
      @from = opts[:from]
      @children = []
    end

    def << (other)
      other.send("#{@from.class.name.downcase}_id=", @from.id)
      @children << other
    end

    def parent_id
      @from.send(@on.to_s.downcase + "_id")
    end


    def each
      @children.each { |c| yield c }
    end

    def all
      @children
    end

    def include?(other)
      @children.include?(other)
    end
  end
end
