require 'nokogiri'

class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement
  has_many :objective_options

  concerned_with :searchable, :taggable, :to_txt

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

  Natures = ['Subjective', 'Objective']

  def is_objective?
    self.nature=='Objective'
  end

  def is_subjective?
    self.nature=='Subjective'
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

    #    self.topics.each do |topic|
    #      self.complexities.each do |complexity|
    #        self.natures.each do |nature|
    #          count = self.tagged_with([topic, complexity, nature]).count
    #          @available << [topic.name, complexity.name, nature.name, count]
    #        end
    #      end
    #    end

    self.topics.product(self.complexities, self.natures).each do |topic_complexity_nature|
      topic_complexity_nature_count = topic_complexity_nature << self.tagged_with(topic_complexity_nature).count
      
      @available << topic_complexity_nature_count
    end
    
    @available
  end
end


