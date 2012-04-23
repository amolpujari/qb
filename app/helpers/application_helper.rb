module ApplicationHelper
  include AttachmentsHelper
  include InputHelpers

  def errors_for(object, message=nil)
    html = ""
    if object and object.errors and not object.errors.blank?
      error_string = ( object.errors.size > 1)? 'errors' : 'error'
      html << "<div id='errorExplanation' class='errorExplanation'>"
      html << "<h2>#{object.errors.size} #{error_string} prohibited this #{object.class.name.downcase} from being saved </h2><p>There were problems with the following fields:</p>"
      html << "<ul>"
      object.errors.full_messages.each do |error|
        html << "<li>#{error}</li>"
      end
      html << "</ul><div class=\"clear\"> </div></div>"
    end
    html
  end

  def formatted_statement(stmt)
    stmt_formatted = simple_format(stmt)
    stmt = stmt_formatted if stmt_formatted.size > 8 rescue stmt
    stmt_space_adjusted = stmt.gsub!('  ','&nbsp;&nbsp;')
    stmt = stmt_space_adjusted if stmt_space_adjusted.size > 2 rescue stmt
  end

end
