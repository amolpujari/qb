class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement

  def title
    statement.title
  end

  acts_as_taggable
  acts_as_taggable_on :levels, :topics

  has_many :level_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag",
    :conditions => "taggings.context = 'levels'"

  has_many :topic_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag",
    :conditions => "taggings.context = 'topics'"

  attr_accessible :level_list, :topic_list

  define_index do
    indexes statement.title, :as => :title
    indexes statement.body, :as => :body
    
    indexes level_tags(:name), :as => :level_tags
    has level_tags(:id), :as => :level_tag_ids, :facet => true

    indexes topic_tags(:name), :as => :topic_tags
    has topic_tags(:id), :as => :topic_tag_ids, :facet => true
    # http://stackoverflow.com/questions/2082399/thinking-sphinx-and-acts-as-taggable-on-plugin

    set_property :delta => true
  end

  Levels = {
    "complexity_qb_easy"      => 'easy',
    "complexity_qb_medium"    => 'medium',
    "complexity_qb_hard"      => 'hard',
    "complexity_qb_very_hard" => 'very_hard',
  }
  
  def complexity
    Levels[level_list.grep(/^complexity_qb_(.*)/).first]
  end

  Topics = {
    "topic_qb_java"           => 'java',
    "topic_qb_dot_net"        => 'dot_net',
    "topic_qb_c_sharp"        => 'c_sharp',
    "topic_qb_ruby"           => 'ruby',
    "topic_qb_databases"      => 'databases',
  }

  def topic
    Topics[topic_list.grep(/^topic_qb_(.*)/).first]
  end

end
