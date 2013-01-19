class TestsController < ApplicationController

  before_filter :prepare_test, :only => [:new, :edit, :show, :update, :sample, :create]
  
  def index
    @tests = Test.all
  end

  def sample
    @questions = @test.sample
    
    respond_to do |format|
      format.html # index.html.erb
      format.text { send_data @questions.text_format, :filename => filename_now }
    end
  end

  def conduct
    if request.post?
    end
  end

  def new
  end

  def edit
  end

  def show
    render :edit
  end

  def create
    @test.test_topics.build params[:test_topics]
    if @test.save
      redirect_to @test, :notice => "Successfully created test."
    else
      render '/tests/new'
    end
  end

  def update
    @test.assign_attributes params[:test]
    @test.update_test_topics params[:test_topics]

    if @test.save
      redirect_to @test, :notice => "Successfully updated test."
    else
      render '/tests/edit'
    end
    
  end

  def destroy
  end

  private

  def filename_now
    "#{Time.now.utc.to_s.gsub('-', '').gsub(':', '').delete(' ')}_test_#{@test.title}.txt"
  end

  def prepare_test
    @test = Test.find params[:id] || Test.new
    @test_topics = @test.test_topics
    @available_questions = Question.available_for_test
  end
end
