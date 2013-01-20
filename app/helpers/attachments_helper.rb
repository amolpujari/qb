module AttachmentsHelper

  def attachments_show(attachable)
    return unless (attachable and attachable.attachments and !attachable.attachments.empty?)
    html = "<div id='attachment_summary'>"
    html << show_first_image_attachment(attachable)
    html << show_image_line(attachable)
    html << show_non_image_attachments(attachable)
    html << "</div>"
    raw(html)
  end

  def attachments_form_for( attachable)
    attachments = attachable.attachments.select{ |attachment| !(attachment.id.nil?) }

    max_allowed = attachable.class.to_s.constantize.max_attachments_allowed
    html = ''
    prepare_additional_upload_count
    attachments.first(max_allowed).each_with_index{|attachment,i| html << index_object(attachment,i)}
    (attachments.length + 1).upto max_allowed do |i|
      max_allowed_not_reached = ( i < max_allowed )
      last_add_more = ( i == ( max_allowed - 1))
      html << "<ul class='list_post reset'>"
      if additional_upload_count_reached
        html << hidden_upload_option(i)
        html << hidden_add_more( last_add_more, i) if max_allowed_not_reached
      else        
        html << show_upload_option(i)
        html << show_add_more( last_add_more, i) if last_additional_upload? && max_allowed_not_reached        
        decrement_additional_upload_count
      end
      html << "</ul>"
    end
    raw(html)
  end

  def show_upload_option( attachment_count)
    upload_option( attachment_count)
  end

  private

  def show_first_image_attachment( attachable)
    image = attachable.first_image_attachment
    return '' if not image
    html  = "<div id='big_size_photo' class='thumbnail_img'>"
    html << link_to(image_tag(image.upload.url(:thumb), :height => 100, :width => 100,:target => '_blank'), image.upload.url)
    html << "</div>"
  end

  def show_non_image_attachments( attachable)
    html = ''
    files = attachable.non_image_attachments
    return '' if files.empty?
    files.each do |file|
      html <<  "<div style='margin:5px;' class='line'><img src='/assets/attachement_icon.jpg'/>&nbsp;<a href='#{file.upload.url}' target='_blank' >Download #{file.upload_file_name}</a></div>"
    end
    html
  end

  def show_image_line( attachable)
    files = attachable.image_attachments
    return '' if files.empty?
    html = "<div class='attachments_imgs'><div>"
    files.each do |file|
      html << "<div id='big_size_photo_#{file.upload_file_name}' style='display:none;'>"
      html << link_to(image_tag(file.upload.url(:thumb), :class=> 'attachment_img'), file.upload.url)
      html << "</div>"
      html << "<a class='attachment_img_link' href='javascript:void(0);' onclick=\"document.getElementById('big_size_photo').innerHTML = document.getElementById('big_size_photo_#{file.upload_file_name}').innerHTML;\">"
      html << "<img class='attachment_img' src='#{file.upload.url(:thumb)}' alt='#{file.upload_file_name}' />"
      html << "</a>"
    end
    html << "</div></div>"
  end

  ADDITIONAL_UPLOAD_OPTIONS_COUNT = 1

  def prepare_additional_upload_count
    @additional_upload_count = ADDITIONAL_UPLOAD_OPTIONS_COUNT
  end

  def additional_upload_count_reached
    @additional_upload_count == 0
  end

  def decrement_additional_upload_count
    @additional_upload_count -= 1
  end

  def last_additional_upload?
    @additional_upload_count == 1
  end

  def index_object( object, index)
    html = "<div id=\"attachment_show_#{index}\" class=\"attachments_imgs\" >"
    if object.image?
      html << link_to(image_tag(object.upload.url(:thumb),
          :border => 0, :class => 'attachment_img'),object.upload.url)
    else
      html << "<img src=\"/assets/attachement_icon.jpg\" />&nbsp;<a href=\"#{object.upload.url}\">#{object.upload_file_name}</a>"
    end
    html << "&nbsp; &nbsp; &nbsp;"
    html << link_to( "Remove", "/attachments/#{object.id}?attachment_number=#{index}",
      :confirm => 'Are you sure you want to delete attachment?',
      :remote=>true,
      :method => :delete
    )
    html << "</div>"
  end

  def hidden_upload_option( attachment_count)
    upload_option( attachment_count, 'none')
  end

  def hidden_add_more( last_element, index)
    add_more( last_element, index, 'none')
  end

  def show_add_more( last_element, index)
    add_more( last_element, index)
  end

  def add_more( last_element, index, display = 'block')
    html = "<div id='add_more_#{index}' style='display:#{display}'>"
    html << "<a href=\"#\" onclick=\"document.getElementById('additional_upload_#{(index+1)}').style.display = 'block';"
    html << "document.getElementById('add_more_#{index}').style.display = 'none';"
    html << "document.getElementById('add_more_#{(index+1)}').style.display = 'block'; increase_popup_height();" unless last_element
    html << "return false;\" >Add More</a>"
    html << "</div>"
    html
  end

  def upload_option( attachment_count, display = 'block')
    html = "<div id=\"additional_upload_#{attachment_count}\" class='line' style=\"display:#{display}\">"    
    html << "<li>"
    html << "<input id=\"input_file_#{attachment_count}\" type=\"file\" name=\"attachment[]\"  accept=\"image, application/pdf, application/msword, text/plain\" />"
    html << "</li>"
    html << "</div>"
  end
end
