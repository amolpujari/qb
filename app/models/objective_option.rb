class ObjectiveOption < ActiveRecord::Base
  attr_accessible :body, :is_correct
  belongs_to :question
end
