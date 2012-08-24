class Question < ActiveRecord::Base
  acts_as_taggable
  
  acts_as_taggable_on :topics
  acts_as_taggable_on :complexities
  acts_as_taggable_on :natures

  attr_accessible :topic_list
  attr_accessible :complexity_list
  attr_accessible :nature_list

  def self.topics
    self.top_topics self.topic_counts.size
  end

  def self.topic_names
    self.topics.map(&:name)
  end

  def self.complexities
    self.top_complexities self.complexity_counts.size
  end

  def self.complexity_names
    self.complexities.map(&:name)
  end

  def self.natures
    self.top_natures self.nature_counts.size
  end

  def self.nature_names
    self.natures.map(&:name)
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