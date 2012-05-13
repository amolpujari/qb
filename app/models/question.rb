class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement
  has_many :objective_options

  def title
    statement.title
  end

  acts_as_taggable

  acts_as_taggable_on :complexities
  attr_accessible :complexity_list
  Complexities = ['Easy', 'Medium', 'Hard', 'Very Hard',]

  acts_as_taggable_on :topics
  attr_accessible :topic_list
  Topics = ['Java', 'dot Net', 'c sharp', 'Ruby', 'Databases',]

  acts_as_taggable_on :natures
  attr_accessible :nature_list
  Natures = ['Subjective', 'Objective']

  def complexity
    complexity_list.first
  end

  def topic
    topic_list.first
  end

  def nature
    nature_list.first
  end

  attr_accessible :delta
  define_index do
    indexes statement.title, :as => :title
    indexes statement.body, :as => :body

    set_property :delta => true
  end

  def update_objective_options options
    return self.objective_options.destroy unless options

    options.reverse!

    self.objective_options.each do |existing|
      updated_one = options.pop

      if updated_one
        existing.body       = updated_one[:body]
        existing.is_correct = updated_one[:is_correct]
        existing.save
      else
        existing.destroy
      end
    end
    
    options.each do |new_one|
      self.objective_options.create new_one
    end
  end
  
end
