require 'nokogiri'

class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement
  has_many :objective_options

  attr_accessor :marks

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

  acts_as_taggable_on :topics
  acts_as_taggable_on :complexities
  acts_as_taggable_on :natures

  attr_accessible :topic_list
  attr_accessible :complexity_list
  attr_accessible :nature_list

  def self.topics
    self.top_topics self.topic_counts.size
  end

  def self.complexities
    self.top_complexities self.complexity_counts.size
  end

  def self.natures
    self.top_natures self.nature_counts.size
  end

  Natures = ['Subjective', 'Objective']

  def topic
    topic_list.first
  end

  def complexity
    complexity_list.first
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

    options = options.values if options.is_a? Hash
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

    options = options.values if options.is_a? Hash
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

  def self.available_for_test
    return @available if @available
    
    @available = []
    
    self.topics.each do |topic|
      self.complexities.each do |complexity|
        self.natures.each do |nature|
          count = self.tagged_with([topic, complexity, nature]).count
          @available << [topic.name, complexity.name, nature.name, count]
        end
      end
    end

    @available
  end

  include TxtFormattable
end

