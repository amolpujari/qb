class TestTopic < ActiveRecord::Base
  attr_accessible :topic, :complexity, :nature, :number_of_questions, :marks_for_each_question
  belongs_to :test

  validates :topic,       :inclusion => { :in => Question.topic_names}
  validates :complexity,  :inclusion => { :in => Question.complexity_names}
  validates :nature,      :inclusion => { :in => Question.nature_names}

  validates :number_of_questions,     :numericality => { :greater_than => 0, :less_than => 61 }
  validates :marks_for_each_question, :numericality => { :greater_than => 0, :less_than => 41 }

  def tags
    [nature, complexity, topic]
  end

  def sample_questions
    Question.tagged_with(tags).sample(number_of_questions).each{|question| question.marks = marks_for_each_question}
  end
end
