module QuestionsHelper
  def render_upload_status
    return unless @failed_upload_question_numbers
    
    html = ""
    
    html << "Successfuly uploaded #{@successfuly_upload_question_numbers.size} questions <br/><br/>" if @successfuly_upload_question_numbers.size > 0

    if @failed_upload_question_numbers.size > 0
      html << "<div id='errorExplanation' class='errorExplanation'>"
      html << "<h2>Following #{@failed_upload_question_numbers.size} questions were not uploaded</h2><p></p>"
      html << "<ul>"
      
      @failed_upload_question_numbers.each do |error|
        html << "<li>#{error[:number]}: #{error[:reason]}</li>"
      end
      html << "</ul><div class=\"clear\"> </div></div>"
    end
    
    html
  end
  
end


