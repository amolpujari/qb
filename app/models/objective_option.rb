class ObjectiveOption < ActiveRecord::Base
  attr_accessible :body, :is_correct
  belongs_to :question

  def to_txt
    Nokogiri::HTML(self.body).text
  end

  def is_correct?
    is_correct
  end
end
