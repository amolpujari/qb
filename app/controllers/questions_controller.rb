class QuestionsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  
  def index
    @questions = Question.all
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
    @statement = @question.statement
    if @statement.save_attachments(params[:attachment]) and @statement.update_attributes(params[:statement])
      redirect_to @question, :notice  => "Successfully updated question."
    else
      @question.errors[:base] << @statement.errors
      @question.errors[:base] << @attachments_errors
      render :edit
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    redirect_to questions_url, :notice => "Successfully destroyed question."
  end
end
