class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement

  def title
    statement.title
  end

  acts_as_taggable
  acts_as_taggable_on :complexities, :topics

  attr_accessible :complexity_list, :topic_list

  define_index do
    indexes statement.title, :as => :title
    indexes statement.body, :as => :body
    
    set_property :delta => true
  end

  Complexities = ['easy', 'medium', 'hard', 'very_hard',]
  Topics = ['java', 'dot net', 'c sharp', 'ruby', 'databases',]
  
  def complexity
    complexity_list.first
  end

  def topic
    topic_list.first
  end

end
