class ObjectiveOption < ActiveRecord::Base
  attr_accessible :statement, :is_correct
  belongs_to :question

  def to_txt
    Nokogiri::HTML(statement ).text
  end

  def is_correct?
    is_correct
  end
end
