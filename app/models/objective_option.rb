class ObjectiveOption < ActiveRecord::Base
  attr_accessible :body
  belongs_to :question
end
