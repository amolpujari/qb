class StatementsController < ApplicationController
  def index
    @statements = Statement.all
  end

  def show
    @statement = Statement.find(params[:id])
  end

  def new
    @statement = Statement.new
  end

  def create
    @statement = Statement.new(params[:statement])
    @statement.save_attachments(params[:attachment])
    if @statement.save
      redirect_to @statement, :notice => "Successfully created statement."
    else
      render :new
    end
  end

  def edit
    @statement = Statement.find(params[:id])
  end

  def update
    @statement = Statement.find(params[:id])
    if @statement.save_attachments(params[:attachment]) and @statement.update_attributes(params[:statement])
      redirect_to @statement, :notice  => "Successfully updated statement."
    else
      render :edit
    end
  end

  def destroy
    @statement = Statement.find(params[:id])
    @statement.destroy
    redirect_to statements_url, :notice => "Successfully destroyed statement."
  end
end
