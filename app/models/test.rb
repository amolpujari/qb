class Test < ActiveRecord::Base
  attr_accessible :title, :duration
  has_many :test_topics

  validates :title, :length => { :in => 6..40 }, :uniqueness => { :case_sensitive => false }
  validates :duration, :numericality => { :greater_than => 9, :less_than => 121 }

  def update_test_topics param_test_topics
    existing_ids = []
    
    param_test_topics.each do |param_test_topic|
      existing = existing_topic param_test_topic[:topic], param_test_topic[:complexity], param_test_topic[:nature]

      if existing
        existing.assign_attributes param_test_topic
        existing.save
        existing_ids << existing.id
      else
        self.test_topics.build param_test_topic
      end
    end

    TestTopic.destroy(self.test_topic_ids - existing_ids)
  end

  def existing_topic topic, complexity, nature
    @_test_topics ||= self.test_topics || []
    @_test_topics.where( :topic => topic, :complexity => complexity, :nature => nature).first
  end
  
  def number_of_questions
    self.test_topics.sum(:number_of_questions)
  end

  def marks
    self.test_topics.sum('number_of_questions * marks_for_each_question').to_i
  end
end
