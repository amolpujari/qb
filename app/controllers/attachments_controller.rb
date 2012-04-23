class AttachmentsController < ApplicationController
  respond_to :js
  # *Description*
  # * Deletes the attachment.
  # *MethodRequestType*
  # * DELETE
  # *Parameters*
  # * attachment_id - ID of the attachement to be deleted.
  # * attachment_number - Number of attachements linked to this post.
  def delete
    Attachment.destroy(params[:id]) unless params[:id].blank? if request.delete?
    @attachment_count = params[:attachment_number] || 0
  end
end
