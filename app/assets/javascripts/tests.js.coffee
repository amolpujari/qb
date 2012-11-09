# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

//= require tinymce
//= require tinymce-jquery

@update_total_marks = ->
  sum = 0
  marks_elements = $("span.total_marks_identifier")
  i = 0

  while i < marks_elements.length
    sum += parseInt(marks_elements[i].innerHTML)
    i++
  $("#total_marks").html sum
  $("#total_marks").effect "highlight", null, 2000
  update_total_questions()

@highlight_topic = (row_count) ->
  $("#topic_" + row_count).effect "highlight", null, 2000
  $("#complexity_" + row_count).effect "highlight", null, 2000
  $("#nature_" + row_count).effect "highlight", null, 2000
  $("#available_questions_" + row_count).parent().effect "highlight", null, 2000
  $("#selected_questions_" + row_count).parent().effect "highlight", null, 2000
  $("#marks_for_each_question_" + row_count).parent().effect "highlight", null, 2000
  $("#total_marks_" + row_count).parent().effect "highlight", null, 2000

@update_total_questions = ->
  total_questions = 0
  questions_elements = $("select.total_questions_identifier")
  i = 0

  while i < questions_elements.length
    total_questions += parseInt(questions_elements[i].value)
    i++
  $("#total_questions").html total_questions
  $("#total_questions").effect "highlight", null, 2000

@update_marks = (row_count) ->
  unless $("#number_of_questions_" + row_count).val()
    $("#total_marks_" + row_count).html 0
  else
    marks_for_each_question = parseInt($("#marks_for_each_question_" + row_count).val())
    selected_questions = parseInt($("#number_of_questions_" + row_count).val())
    $("#total_marks_" + row_count).html marks_for_each_question * selected_questions
  $("#total_marks_" + row_count).effect "highlight", null, 2000
  update_total_marks()

@update_selected_questions_list = (row_count, max) ->
  html = "<select name=\"test_topics[][number_of_questions]\" id=\"number_of_questions_" + row_count + "\" onchange=\"update_marks(" + row_count + ",this.value);\" class=\"total_questions_identifier\"  style=\"width:44px;\" >"
  start = 1
  start = 0  if max is 0
  i = start

  while i <= max
    html += "<option value='" + i + "'>" + i + "</option>"
    i++
  html << "</select>"
  $("#selected_questions_" + row_count).html html
  $("#number_of_questions_" + row_count).effect "highlight", null, 2000
  update_marks row_count, start

@update_question_count = (row_count) ->
  topic = $("select#topic_" + row_count).val()
  complexity = $("select#complexity_" + row_count).val()
  nature = $("select#nature_" + row_count).val()
  if topic is "" or complexity is "" or nature is ""
    update_selected_questions_list row_count, 0
    return 0
  i = 0

  while i < available_questions.length
    if available_questions[i].topic is topic and available_questions[i].complexity is complexity and available_questions[i].nature is nature
      $("span#available_questions_" + row_count).html available_questions[i].count
      update_selected_questions_list row_count, available_questions[i].count
      return available_questions[i].count
    i++

@check_marks = ->
  total_marks_element = $("span.total_marks_identifier")
  i = 0

  while i < total_marks_element.length
    if parseInt(total_marks_element[i].innerHTML) is 0
      alert "You must select at least 1 question for the topic"
      
      #highlight_topic(i); i is index here not for js_counter
      return false
    i++
  true

@check_marks_and_add_topic = ->
  return false  unless check_marks()
  add_topic()

@add_topic = ->
  $("tr#new_topic_replacement").replaceWith new_topic.replace(/js_counter/g, topic_counter)
  update_question_count topic_counter
  topic_counter++
  number_of_topics++

@remove_topic = (row_count) ->
  if number_of_topics is 1
    alert "At least one topic require."
    return
  $("#topic_count_" + row_count).remove()
  number_of_topics--
  update_total_marks()

@check_duplicate_topic_and_question = (row_count) ->
  selected_topics = new Array()
  selected_complexities = new Array()
  selected_natures = new Array()
  topic_elements = $("select.topic_identifier")
  complexity_elements = $("select.complexity_identifier")
  nature_elements = $("select.nature_identifier")

  #refresh available question count on 'Please Select'
  if $("#topic_" + row_count).val() is "" or $("#complexity_" + row_count).val() is "" or $("#nature_" + row_count).val() is ""
    $("#available_questions_" + row_count).html "0"
    update_selected_questions_list row_count, 0
  i = 0

  while i < topic_elements.length
    selected_topics.push topic_elements[i].value
    selected_complexities.push complexity_elements[i].value
    selected_natures.push nature_elements[i].value
    i++
  duplicate = topic_exists(selected_topics, selected_complexities, selected_natures)
  if duplicate
    alert "You can select particular topic, complexity and type only once"
    $("#topic_" + row_count).val ""
    $("#complexity_" + row_count).val ""
    $("#nature_" + row_count).val ""
    $("#available_questions_" + row_count).html "0"
    $("#selected_questions_" + row_count).html "0"
    highlight_topic row_count
  update_question_count row_count

@topic_exists = (selected_topics, selected_complexities, selected_natures) ->
  duplicate = false
  i = 0

  while i < number_of_topics
    current_topic = selected_topics[i]
    current_complexity = selected_complexities[i]
    current_nature = selected_natures[i]
    unless current_topic is "" or current_complexity is "" or current_nature is ""
      j = i + 1

      while j < number_of_topics
        duplicate = true  if selected_topics[j] is current_topic and selected_complexities[j] is current_complexity and selected_natures[j] is current_nature
        j++
    i++
  duplicate

@validate_test = ->
  if $("#test_title").value is "" or $("#test_title").value.length < 4
    alert "Test title cannot be blank. Should be minimum 4 characters"
    return false
  return false  unless check_marks()
  true

@conduct_test = (id) ->
  $.get '/tests/'+id+'/conduct'

