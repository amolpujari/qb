module InputHelpers

  def asterisk
    "<span style=\"color: red; font-weight: bold;\">*</span>&nbsp;"
  end

  def input_label( label, mandatory = false)
    return ' ' if label.length < 2
    label = label.gsub('_',' ').camelize
    label << asterisk if mandatory
    #"<div style=\"width:98%;margin-top:10px;\">#{label}:</div>"
    "<label>#{label}:</label>"
  end

  def obj_s
    controller_name.singularize.to_s
  end

  def input_checkbox(input, options = {})
    html = ''
    object = options[:object]? options[:object] : obj_s
    label = options[:label]? options[:label] : input
    options[:checked_value] ||= true
    options[:unchecked_value] ||= false
    #element_id = "#{object}_#{input}"
    "<div class=\"control-group\"><div class=\"controls\">#{label}: #{check_box(object, input, options, options[:checked_value], options[:unchecked_value])}</div>/div>"
  end

  def input_date(input, options = {})
    html = ''
    object = options[:object]? options[:object] : obj_s
    label = options[:label]? options[:label] : input
    disabled = (options[:disabled] == false ? true : false)
    html  = input_label(label, options[:mandatory])
    #html << date_select(object, input, {:end_year=>Date.current.year,:start_year => 1910,:prompt => {:day => 'Select day', :month => 'Select month', :year => 'Select year' }},{:disabled => disabled})
    html << '<link type="text/css" rel="stylesheet" media="screen" href="/stylesheets/calendar_date_select/default.css"></link>'
    html << javascript_include_tag('/javascripts/calendar_date_select/calendar_date_select')
    html << calendar_date_select(object, input, {:disabled => disabled, :year_range => [1970, Date.current.year], :popup => 'force', :prompt => {:day => 'Select day', :month => 'Select month', :year => 'Select year'} , :size => 15,  :class => "input_106", :onclick => options[:onclick]})
  end

  def input_line_text(input, options = {})
    html = ''
    object = options[:object]? options[:object] : obj_s
    label = options[:label]? options[:label] : input
    label_html  = input_label(label, options[:mandatory])
    password = ( input.include? 'password')? "type='password'" : ''
    data  = eval("@#{object}.#{input}") rescue nil
    data ||= options[:value]
    element_id = "#{object}_#{input}"
    help = options[:help]? "onfocus=\"on_focus_clear_help_msg( '#{element_id}', '#{options[:help]}');\" onblur=\"on_blur_show_help_msg( '#{element_id}', '#{options[:help]}');\"" : ''
    disabled = (options[:disabled] == false ? "disabled" : "")
    html << "<div class=\"control-group\"><div class=\"controls\">#{label_html}<input style=\"width:90%;\" #{password} #{disabled} name='#{object}[#{input}]' value='#{h data}' type='text' id='#{element_id}' #{help} /></div></div>"
  end

  def input_multiline_text(input, options = {})
    html = ''
    object = options[:object]? options[:object] : obj_s
    label = options[:label]? options[:label] : input
    disabled = (options[:disabled] ? "disabled" : "")
    label_html  = input_label(label, options[:mandatory])
    rows  = options[:textarea_rows]? options[:textarea_rows] : 14
    cols  = options[:textarea_cols]? options[:textarea_cols] : 98
    autofocus  = options[:autofocus]? options[:autofocus] : ''
    data  = eval("@#{object}.#{input}") rescue nil
    element_id = "#{object}_#{input}"
    help = options[:help]? "onfocus=\"on_focus_clear_help_msg( '#{element_id}', '#{options[:help]}');\" onblur=\"on_blur_show_help_msg( '#{element_id}', '#{options[:help]}');\"" : ''
    value = options[:value]? options[:value] : ''
    data =  (data || value).html_safe
    html << "<div class=\"control-group\"><div class=\"controls\"  style=\"width:78%;\" >#{label_html}<textarea rows='#{rows}' cols='#{cols}' autofocus='#{autofocus}' #{disabled} name='#{object}[#{input}]' id='#{object}_#{input}' #{help} >#{data}</textarea></div></div>"
  end

  def input_tinymce(input, options = {})
    html = ''
    object = options[:object]? options[:object] : obj_s
    label = options[:label]? options[:label] : input
    disabled = (options[:disabled] == false ? "disabled" : "")
    label_html  = input_label(label, true)
    rows  = options[:tinymce_rows]? options[:tinymce_rows] : 15
    data  = eval("@#{object}.#{input}") #rescue nil
    element_name = "#{object}_#{input}"
    html << "<div class=\"control-group\"><div class=\"controls\" >#{label_html}<textarea  style=\"width:91%;\"  class=\"tinymce\" rows='#{rows}' #{disabled} name='#{object}[#{input}]' id='#{element_name}' #{options[:html]} >#{data}</textarea></div></div>"
    #html << tinymce
    html << render(:partial => 'layouts/tinymce', :locals => {:element_name => element_name })
  end

  def input_attachments(options = {})
    html = ''
    object = options[:object]? options[:object] : obj_s
    instance = eval("@#{object}")
    label = options[:label]? options[:label] : 'Attachments'
    html = "<div class=\"control-group\"><div class=\"controls\"><p>#{label}</p>";
    html << attachments_form_for( instance)
    html << '</div></div>'
  end

  def input_tags(options = {})
    object = options[:object]? options[:object] : obj_s
    instance = eval("@#{object}")
    html = input_label('tags')
    html << "<div class=\"control-group\"><div class=\"controls\" ><input type='text' name='tags' id='tags' style='float:left;width:99%;' value='#{h instance.tag_list.join(',')}'/>"
    i18n_help = t "label_tags_help_comma_separated"
    html << '<span style="margin-top:1px;"><small>'
    html << i18n_help
    html << '</small></span></div></div>'
  end

  #  def input_form( object, inputs, options = {})
  #    # Please do not overirde options
  #    html  = "<div id='form'>"
  #    html << error_messages_for(object) if inputs.include?(:error_messages)
  #    html << "<table cellspacing='10' cellpadding='1' style='float:left;width:100%; float:left;'>"
  #    html << "<tr><td>#{input_line_text(object, 'title', { :mandatory => true, :help => options[:title_help]})}  </td></tr>" if inputs.include?(:title)
  #    html << "<tr><td>#{input_multiline_text(object, 'description', { :mandatory => true})}                      </td></tr>" if inputs.include?(:description)
  #    html << "<tr><td>#{input_tinymce(object, 'description', { :tinymce_rows => options[:tinymce_rows]})}        </td></tr>" if inputs.include?(:rich_text_description)
  #    html << "<tr><td>#{input_attachments(object)}                                                                        </td></tr>" if inputs.include?(:attachments)
  #    html << "<tr><td>#{input_tags(object)}                                                                      </td></tr>" if inputs.include?(:tags)
  #    html << "</table>"
  #    html << "</div>"
  #  end

  def input_collection_select(input, options ={})
    object = options[:object]? options[:object] : obj_s
    label = options[:label]? options[:label] : input
    conditions = options[:conditions]? options[:conditions] : {}
    input_field = options[:column_name].blank? ? input.to_s+"_id" : options[:column_name]
    display_field =  options[:display_field].blank? ? "name" : options[:display_field]
    items = options[:collection] unless options[:collection].blank?
    unless items
      unless options[:model].blank?
        klass = options[:model].camelize
        items = eval "#{klass}.find(:all, :order => '#{display_field}', :conditions => conditions)"
      end
    end
    items = eval "#{input.camelize}.all" unless items
    html = input_label(label, options[:mandatory])
    html << collection_select( object, input_field, items, :id, display_field, {:style => 'width:98%'}, :onchange => options[:onchange], :onkeyup => options[:onkeyup])
  end





  
  # overridden input_multiline_text
  def input_answers(count, options = {})
    input = 'body'
    object = "question.objective_options[#{count}]"
    disabled = (options[:disabled] ? "disabled" : "")
    html  = input_answer_label(count, options[:mandatory])
    data  = eval("@#{object}.#{input}") rescue nil
    element_id = "#{object}_#{input}"
    help = options[:help]? "onfocus=\"on_focus_clear_help_msg( '#{element_id}', '#{options[:help]}');\" onblur=\"on_blur_show_help_msg( '#{element_id}', '#{options[:help]}');\"" : ''
    value = options[:value]? options[:value] : ''
    data =  (data || value).html_safe
    html << "<div id='objective_option_#{count}'><textarea style='float:left;' cols='98' rows='4' #{disabled} name='objective_options[#{count}][body]' #{help} >#{data}</textarea></div>"
  end

   def input_answer_label( count, mandatory = false)
    checked = @question.objective_options[count].is_correct ? 'checked' : '' rescue ''
    label = "Option #{(count+1)}"
    return ' ' if label.length < 2
    label = label.gsub('_',' ').camelize
    mandatory ? label <<  "<span style=\"color: red; font-weight: bold;\">*</span>&nbsp;" : label << "<span style=\"color: red; font-weight: bold;\">&nbsp;</span>&nbsp;"
    "<div style='width:780px;float:left;margin-top:13px;'>#{label}:</div><div style='width:150px;float:left;margin-top:13px;'>correct one? : <input type='checkbox' id='question_answers_#{count}_checkbox' name='objective_options[#{count}][is_correct]' value='1' #{checked} /></div>"
  end

  def input_bold_label( label, mandatory = false)
    return ' ' if label.length < 2
    label = label.gsub('_',' ').camelize
    label << asterisk if mandatory
    "<div style=\"width:98%;margin-top:10px;\"><b>#{label}:</b></div>"
  end


end

