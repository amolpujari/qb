class Question < ActiveRecord::Base
  Natures = ['Subjective', 'Objective']

  def is_objective?
    self.nature=='Objective'
  end

  def is_subjective?
    self.nature=='Subjective'
  end
end


