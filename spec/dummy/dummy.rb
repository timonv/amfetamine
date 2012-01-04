class Dummy < Dada::Base
  @@children = [] # unrelated to relationships!

  dada_attributes :title, :description
  validates_presence_of :title, :description

  has_many_resources :children

  before_create :action_before_create
  after_create :action_after_create

  before_save :action_before_save
  after_save :action_after_save

  def to_hash
    {
      :title => title,
      :description => description,
      :id => id
    }
  end


  # Needed for proper ID tracking
  def initialize(args={})
    @@children << self
    super(args)
  end

  def self.children
    @@children ||= []
  end

  def action_before_create
    Dada.logger.warn "Yo, BEFORE CREATE called"
  end

  def action_after_create
    Dada.logger.warn "Yo, AFTER CREATE called"
  end

  def action_before_save
  end

  def action_after_save
  end

end
