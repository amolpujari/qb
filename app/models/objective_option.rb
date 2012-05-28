class ObjectiveOption < ActiveRecord::Base
  attr_accessible :body, :is_correct
  belongs_to :question

  def text
    Nokogiri::HTML(self.body).text
  end
end
