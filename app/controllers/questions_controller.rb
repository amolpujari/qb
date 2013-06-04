class QuestionsController < ApplicationController
  before_filter :question
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :validate_tags, :only => [:create, :update]

  def index
    tags = filter_tags

    # http://stackoverflow.com/questions/2082399/thinking-sphinx-and-acts-as-taggable-on-plugin

    @questions = Question.tagged_with(tags, :match_all => false).paginate(:page => params[:page]) unless tags.blank?
    @questions ||= Question.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.text { send_data @questions.text_format, :filename => "#{Time.now.utc.to_s.gsub('-', '').gsub(':', '').delete(' ')}_questions_#{tags.join('_')}.txt" }
    end
  end

  def show
  end

  def new
  end

  def create
    @question.submitter = current_user
    @question.assign_attributes params[:question]
    @question.topic_list = params[:question][:topic_list] unless params[:question][:topic_list].blank?
    @question.assign_objective_options params[:objective_options]

    if @question.save_attachments(params[:attachment]) and @question.save!
      redirect_to @question, :notice => "Successfully created question."

    else
      @question.errors[:base] << @attachments_errors
      render :new
    end
  end

  def edit
  end

  def update
    if @question.submitter != current_user
      flash[:error] = "For now, only owner can edit this."
      render :edit
      return
    end

    @question.assign_attributes params[:question]
    @question.topic_list = params[:question][:topic_list] unless params[:question][:topic_list].blank?
    @question.update_objective_options params[:objective_options]
    
    @question.assign_attributes :delta => true
    
    if @question.save_attachments(params[:attachment]) and @question.update_attributes(params[:statement]) and @question.save
      redirect_to @question, :notice  => "Successfully updated question."

    else
      @question.errors[:base] << @attachments_errors
      render :edit
    end
  end

  def destroy
    #@question = Question.find_by_id params[:id]
    #@question.destroy
    redirect_to questions_url, :notice => "feature inactive."
  end

  def import
    if request.post?
      importer = QuestionImporter.new params[:questions_file], current_user

      @upload_error = importer.upload_error
      @failed_upload_question_numbers = importer.failed_upload_question_numbers
      @successfuly_upload_question_numbers = importer.successfuly_upload_question_numbers
      @questions = importer.successfuly_upload_questions
      
      if not @upload_error
        render :index, :notice => 'Questions uploaded!'

      else
        @questions = Question.paginate(:page => params[:page])
        flash[:error] = "Questions upload failed: #{@upload_error}"
        render :index
      end
    end
  end

  private

  def validate_tags
    params[:question][:topic_list] = params[:other_topic] if params[:question][:topic_list]=='Other'
    params[:question].delete :topic_list if params[:question][:topic_list].downcase.include? 'other'
  end

  def filter_tags
    tags = []
    tags << params[:complexity].to_s  unless params[:complexity].blank?
    tags << params[:topic].to_s       unless params[:topic].blank?
    tags << params[:search].to_s      unless params[:search].blank?
    tags = tags.collect{ |tag| tag.downcase }
    tags = tags.uniq.compact
  end

  def question
    @question ||= Question.find_by_id(params[:id]) || Question.new
  end
end
