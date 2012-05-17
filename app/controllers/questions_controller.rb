class QuestionsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  
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
    @question = Question.find(params[:id])
    @statement = @question.statement
  end

  def new
    @question = Question.new
    @statement = Statement.new
    @question.statement = @statement
  end

  def create
    @statement = Statement.new(params[:statement])
    @question = Question.new(params[:question])
    @question.statement = @statement
    @statement.user = current_user
    @question.assign_objective_options params[:objective_options]

    if @statement.save_attachments(params[:attachment]) and @question.save!
      redirect_to @question, :notice => "Successfully created question."
    else
      @question.errors[:base] << @statement.errors
      @question.errors[:base] << @attachments_errors
      render :new
    end
  end

  def edit
    @question = Question.find(params[:id])
    @statement = @question.statement
  end

  def update
    @question = Question.find(params[:id])
    @question.assign_attributes params[:question]
    @question.assign_attributes :delta => true
    @question.update_objective_options params[:objective_options]
    
    @statement = @question.statement
    if @statement.save_attachments(params[:attachment]) and @statement.update_attributes(params[:statement]) and @question.save
      redirect_to @question, :notice  => "Successfully updated question."
    else
      @question.errors[:base] << @statement.errors
      @question.errors[:base] << @attachments_errors
      render :edit
    end
  end

  def destroy
    #@question = Question.find(params[:id])
    #@question.destroy
    redirect_to questions_url, :notice => "feature inactive."
  end

  include Importer
  def import
    if request.post?
      if questions_uploaded_successfuly_from params[:questions_file]
        @questions = Question.find(:all, :order => ' created_at desc ', :limit => @successfuly_upload_questions.size)
        render :index, :notice => 'Questions uploaded!'
      else
        @questions = Question.paginate(:page => params[:page])
        puts "----------------------------Questions upload failed: #{@upload_error}"
        flash[:error] = "Questions upload failed: #{@upload_error}"
        render :index
      end
    end
  end

  private

  def filter_tags
    tags = []
    tags << params[:complexity].to_s  unless params[:complexity].blank?
    tags << params[:topic].to_s       unless params[:topic].blank?
    tags << params[:search].to_s      unless params[:search].blank?
    tags = tags.collect{ |tag| tag.downcase }
    tags = tags.uniq.compact
  end
end
