class CandidatesController < ApplicationController
  before_filter :check_browser, :only => [:my_test]

  def mytest
    tp = TestPaper.scheduled.where(:pin => params[:pin]).first
    render "invalid_pin" and return unless tp
  end

  private

  def check_browser
  end
end
