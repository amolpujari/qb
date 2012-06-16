class TestsController < ApplicationController
  
  def index
    @tests = Test.all
  end

  def show
    @test = Test.find_by_id params[:id]
    render :edit
  end

  def sample
    @test = Test.find_by_id params[:id]
    @questions = @test.sample
    
    respond_to do |format|
      format.html # index.html.erb
      format.text { send_data @questions.text_format, :filename => "#{Time.now.utc.to_s.gsub('-', '').gsub(':', '').delete(' ')}_test_#{@test.title}.txt" }
    end
  end

  def new
    @test = Test.new
  end

  def create
    @test = Test.new params[:test]
    @test.test_topics.build params[:test_topics]
    if @test.save
      redirect_to @test, :notice => "Successfully created test."
    else
      render '/tests/new'
    end
  end

  def edit
    @test = Test.find_by_id params[:id]
  end

  def update
    @test = Test.find_by_id params[:id]
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
end
