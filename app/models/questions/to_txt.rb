class Question < ActiveRecord::Base
  def to_txt
    text_answer = ''
    
    option_labels = ['a', 'b', 'c', 'd', 'e']
    str = "\n#{self.text_body}\n\n Options:\n\n"
    self.objective_options.each_with_index do |option, index|
      str << "(#{option_labels[index]})\n#{option.to_txt}\n\n"
      
      text_answer << "#{option_labels[index]}, " if option.is_correct?
    end
    str << "\n"

    [str, text_answer]
  end
end

class Array
  def text_format
    text_answers = ''
    text = ''
    
    self.each_with_index do |question, index|
      text << "\n"
      text << "(#{index+1})"
      question_text, question_answer = question.to_txt
      text << question_text
      text << "\n"

      text_answers << "(#{index+1}) #{question_answer}"
    end

    text << "\n"*80
    text << "Answers:\n"
    text << "-"*80
    text << "\n"
    text << text_answers
    text << "\n"
    text << "-"*80
    text << "\n"*10

    text
  end
end