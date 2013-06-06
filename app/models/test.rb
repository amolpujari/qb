class Test < ActiveRecord::Base
  attr_accessible :title, :duration

  has_many :test_topics

  validates :title, :length => { :in => 6..40 }, :uniqueness => { :case_sensitive => false }
  validates :duration, :numericality => { :greater_than => 9, :less_than => 121 }

  def conduct emails, current_user
    emails = emails.split(/[, ;]/i).collect{ |email| email.strip }.select{ |email| !email.blank? }
    invalid_emails = []

    emails.each do |email|
      candidate = Candidate.find_or_create_by_email email
      if candidate.errors.any?
        invalid_emails << email
        next
      end

      test_paper = TestPaper.new
      test_paper.minutes_left   = duration + 1
      test_paper.candidate      = candidate
      test_paper.summary        = summary
      test_paper.scheduler      = current_user
      test_paper.save!
      test_paper.questions      = sample_questions.map(&:id)
    end

    emails -= invalid_emails
    status = ""
    status << "Sent test invite to #{emails.join(',')}. "           if emails.any?
    status << "Found invalid emails #{invalid_emails.join(',')}. "  if invalid_emails.any?
    status
  end

  def summary
    "#{title} test, for #{number_of_questions} questions, #{marks} marks"
  end

	def update_test_topics param_test_topics
	  existing_ids = []

		param_test_topics.each do |param_test_topic|
			existing = existing_topic param_test_topic[:topic], param_test_topic[:complexity], param_test_topic[:nature]

			if existing
				existing.assign_attributes param_test_topic
		    existing.save
			  existing_ids << existing.id
			else
        test_topics.build param_test_topic
			end
		end

		TestTopic.destroy(test_topic_ids - existing_ids)
  end

  def existing_topic topic, complexity, nature
    test_topics.where( :topic => topic, :complexity => complexity, :nature => nature).first
  end
  
  def number_of_questions
    test_topics.sum(:number_of_questions)
  end

  def marks
    test_topics.sum('number_of_questions * marks_for_each_question').to_i
  end

  def sample_questions
    test_topics.map(&:sample_questions).flatten
  end
  alias :sample  :sample_questions

end
