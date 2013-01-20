class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement

  resourcify

  concerned_with :searchable, :taggable, :to_txt, :objective, :natures

  attr_accessor :marks

  def title
    "#{self.text_body[0..200]} ..."
  end

  delegate :body, :text_body, :to => :statement

  def self.available_for_test
    topics.product(complexities, natures).collect do |topic_complexity_nature|
      topic_complexity_nature << tagged_with(topic_complexity_nature).count
    end
  end
end


