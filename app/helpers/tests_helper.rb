module TestsHelper
  def input_duration
    html = '<select name="test[duration]" class="span1">'
    for i in [30, 45, 60, 75, 90, 120] do
      if @test.duration == i
        html << "<option selected id='candidate_#{i}' value='#{i}'>#{i}</option>"
      else
        html << "<option id='candidate_#{i}' value='#{i}'>#{i}</option>"
      end
    end
    html << '</select> <span class="add-on">minutes</span>'
  end
  
  def input_marks_for_each_question
    html = '<select id="marks_for_each_question_js_counter" name="test_topics[][marks_for_each_question]" class="span1" onchange="update_marks(js_counter);">'
    for i in [1, 2, 4, 5, 8, 10, 15, 20, 25] do
      if @test.duration == i
        html << "<option selected id='candidate_#{i}' value='#{i}'>#{i}</option>"
      else
        html << "<option id='candidate_#{i}' value='#{i}'>#{i}</option>"
      end
    end
    html << '</select>'
  end
end