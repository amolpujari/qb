class Question < ActiveRecord::Base
  acts_as_taggable
  
  acts_as_taggable_on :topics
  acts_as_taggable_on :complexities
  acts_as_taggable_on :natures

  attr_accessible :topic_list
  attr_accessible :complexity_list
  attr_accessible :nature_list

  def topics
    top_topics topic_counts.size
  end

  def topic_names
    topics.map(&:name)
  end

  def complexities
    top_complexities complexity_counts.size
  end

  def complexity_names
    complexities.map(&:name)
  end

  def natures
    top_natures nature_counts.size
  end

  def nature_names
    natures.map(&:name)
  end
  
  def topic
    topic_list.first
  end

  def complexity
    complexity_list.first
  end

  def nature
    nature_list.first
  end
end