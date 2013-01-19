require 'nokogiri'

class Statement < ActiveRecord::Base
  attr_accessible :body
  can_have_attachments :max => 5
  belongs_to :user
  belongs_to :question, :conditions => {'statements.statement_for_type' => 'Question' }, :foreign_key => :statement_for_id

  def text_body
    Nokogiri::HTML(body).text
  end
end
