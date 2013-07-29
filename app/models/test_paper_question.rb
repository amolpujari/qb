class TestPaperQuestion < ActiveRecord::Base
  belongs_to :question
  belongs_to :test_paper
end
