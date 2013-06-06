class TestPapersController < ApplicationController
  #layout 'one_column'
  
  def index
    @test_papers = TestPaper.where(:status => "scheduled").includes(:candidate, :scheduler).page(@page).per(@per_page)
  end
end
