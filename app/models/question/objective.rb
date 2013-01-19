class Question < ActiveRecord::Base
  has_many :objective_options

  def options
    return unless self.is_objective?
    
    self.objective_options.select{ |option| option.body and option.body.strip.length > 0 }
  end

  def update_objective_options options
    return self.objective_options.destroy unless options

    options = options.values if options.is_a? Hash.collect
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
end
