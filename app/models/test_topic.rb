class TestTopic < ActiveRecord::Base
  attr_accessible :topic, :complexity, :nature, :number_of_questions, :marks_for_each_question
  belongs_to :test

  validates :topic,       :inclusion => { :in => Question.topics.collect{|t| t.name}}
  validates :complexity,  :inclusion => { :in => Question.complexities.collect{|t| t.name}}
  validates :nature,      :inclusion => { :in => Question.natures.collect{|t| t.name}}

  validates :number_of_questions, :numericality => { :greater_than => 0, :less_than => 61 }
  validates :marks_for_each_question, :numericality => { :greater_than => 0, :less_than => 41 }

  def tags
    [self.nature, self.complexity, self.topic]
  end

  def sample_questions
    Question.tagged_with(self.tags).sample(self.number_of_questions)#.marks(self.marks_for_each_question)
  end
end
