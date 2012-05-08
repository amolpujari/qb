class QuestionsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  
  def index
    tags = []
    tags << params[:level].to_s unless params[:level].blank?
    tags << params[:topic].to_s unless params[:topic].blank?

    # http://stackoverflow.com/questions/2082399/thinking-sphinx-and-acts-as-taggable-on-plugin
    unless params[:search].blank?
      condition = { :title => corrected_search_filter, :body => corrected_search_filter }
      condition[:level_tags] = params[:level].to_s unless params[:level].blank?
      condition[:topic_tags] = params[:topic].to_s unless params[:topic].blank?
      @questions = Question.search params[:search].to_s, :conditions => condition, :page => params[:page]

    else
      @questions = Question.tagged_with(tags, :match_all => false).paginate(:page => params[:page]) unless tags.blank?
      
    end

    @questions ||= Question.paginate(:page => params[:page])
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

    question_attrs = params[:question]
    question_attrs[:delta] = true
    
    @statement = @question.statement
    if @statement.save_attachments(params[:attachment]) and @statement.update_attributes(params[:statement]) and @question.update_attributes(question_attrs)
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
end
