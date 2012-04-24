class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement

  def title
    statement.title
  end

  acts_as_taggable
  acts_as_taggable_on :levels, :topics
  attr_accessible :level_list, :topic_list

  Levels = {
    "complexity_qb_easy"        => 'easy',
    "complexity_qb_medium"      => 'medium',
    "complexity_qb_hard"        => 'hard',
    "complexity_qb_very_hard"   => 'very_hard',
  }
  def complexity
    Levels[level_list.grep(/^complexity_qb_(.*)/).first]
  end

  Topics = {
    "topic_qb_java"      => 'java',
    "topic_qb_.net"      => '.net',
    "topic_qb_c#"        => 'c#',
    "topic_qb_ruby"      => 'ruby',
    "topic_qb_databases" => 'databases',
  }
  def topic
    Topics[topic_list.grep(/^topic_qb_(.*)/).first]
  end

end
