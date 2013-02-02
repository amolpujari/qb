class Question < ActiveRecord::Base
  belongs_to :submitter, :class_name => 'User'
  
  can_have_attachments :max => 5

  resourcify

  concerned_with :searchable, :taggable, :to_txt, :objective, :natures

  attr_accessor :marks

  def text
    Nokogiri::HTML(statement).text
  end
  
  def title
    "#{self.text[0..200]} ..."
  end

  def self.available_for_test
    topics.product(complexities, natures).collect do |topic_complexity_nature|
      topic_complexity_nature << tagged_with(topic_complexity_nature).count
    end
  end
end


