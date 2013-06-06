class TestPaper < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :scheduler, :class_name => "User", :foreign_key => :created_by
  has_many :test_paper_questions

  validates :minutes_left,     :numericality => { :greater_than => -1, :less_than => 60  }, :allow_nil => true
  validates :objective_score,  :numericality => { :greater_than => -1, :less_than => 100 }, :allow_nil => true

  def before_create
    objective_score = 0
    pin = Time.now.to_i.to_s
  end

  def questions= question_ids
    sql = "INSERT INTO test_paper_questions (test_paper_id, question_id) VALUES "
    question_ids.each do |question_id|
      sql << "(#{id}, #{question_id}),"
    end
    sql = sql[0..-2]
    connection.execute sql
  end
end
