require 'nokogiri'

class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement
  has_many :objective_options

  def title
    "#{self.text_body[0..200]} ..."
  end

  def body
    statement.body
  end

  def text_body
    Nokogiri::HTML(self.body).text
  end

  acts_as_taggable

  acts_as_taggable_on :complexities
  attr_accessible :complexity_list
  Complexities = ['Easy', 'Medium', 'Hard', 'Very Hard',]

  acts_as_taggable_on :topics
  attr_accessible :topic_list
  Topics = ['Java', 'dot Net', 'c sharp', 'Ruby', 'Databases',]

  acts_as_taggable_on :natures
  attr_accessible :nature_list
  Natures = ['Subjective', 'Objective']

  def complexity
    complexity_list.first
  end

  def topic
    topic_list.first
  end

  def nature
    nature_list.first
  end

  def is_objective?
    self.nature=='Objective'
  end

  def is_subjective?
    self.nature=='Subjective'
  end

  attr_accessible :delta
  define_index do
    indexes statement.body, :as => :body

    set_property :delta => true
  end

  def options
    return unless self.is_objective?
    options = self.objective_options.collect do |option|
      option if option.body and option.body.strip.length > 0
    end
    options.compact!
  end

  def update_objective_options options
    return self.objective_options.destroy unless options

    options.reverse!

    self.objective_options.each do |existing|
      updated_one = options.pop

      if updated_one
        existing.body       = updated_one[:body]
        existing.is_correct = updated_one[:is_correct]
        existing.save
      else
        existing.destroy
      end
    end

    options.each do |new_one|
      self.objective_options.create new_one
    end
  end

  def assign_objective_options options
    return self.objective_options.destroy unless options

    options.reverse!

    self.objective_options.each do |existing|
      updated_one = options.pop

      if updated_one
        existing.body       = updated_one[:body]
        existing.is_correct = updated_one[:is_correct]
        #existing.save
      else
        existing.destroy
      end
    end

    options.each do |new_one|
      self.objective_options.new new_one
    end
  end

  def text
    " \n#{self.text_body}"
  end
end


class Array
  def text_format
    _text = ''
    self.each_with_index do |item, index|
      _text << "\n"
      _text << "(#{index})"
      _text << item.text
      _text << "\n"
    end
    _text
  end
end