include Spreadsheet
require 'set'

module ImportQuestions
  MIN_SIZE = 7168          #7Kb
  MAX_SIZE = 10485760      #10Mb
  
  def questions_uploaded_successfuly_from file
    @upload_questions_submitter_id = current_user.id
    #@upload_questions_moderator_id = nil
    #@upload_questions_status = 'moderated'

    if file.blank?
      @upload_error = 'Invalid file'
      return
    end
    
    if not (File.extname(file.original_filename).eql? '.xls')
      @upload_error = 'Invalid file'
      return
    end

    file_path = save_file_on_disk file

    if File.size(file_path) < MIN_SIZE
      @upload_error = 'Blank file'
      File.delete file_path
      return
    end

    if File.size(file_path) > MAX_SIZE
      @upload_error = 'File size too large, allowed upto 10 MB only'
      File.delete file_path
      return
    end
    
    if not process_questions_xls file_path
      File.delete file_path
      return
    end
    
    File.delete file_path
    true
  end

  private

  def save_file_on_disk(file)
    begin
      input_path = Rails.root.join("public/questions_upload/").to_s
      filename = Time.now.strftime("%Y%m%d%H%M%S") + '_' + file.original_filename.gsub(' ','_')
      file_path = input_path + filename
      File.open(file_path, "wb") { |disk_file| disk_file.write( file.read)}
    rescue
      @upload_error = 'Could not write on disk'
      return
    end
    file_path
  end

  def process_questions_xls(file_path)
    @failed_upload_questions = []
    @successfuly_upload_questions = []
    
    begin
      xls = Spreadsheet.open file_path
      first_sheet = xls.worksheet 0
    rescue Exception => e
      @upload_error = e.message
      puts "upload error: #{@upload_error}"
      return
    end

    first_sheet.each_with_index do | columns, row|
      if row == 0
        return if not header_checks_ok? columns
      else
        process_question columns
      end
    end
  end

  def header_checks_ok? columns
    if columns.size < 10
      @upload_error = '10 header columns expected'
      return
    end

    expected_headers = ['No.', 'Topic', 'Complexity Level', 'Question','A','B','C','D','E','Correct Answers']

    expected_headers.each_with_index do |expected_header, index|
      if not ( columns[index].casecmp(expected_header) == 0)
        @upload_error = "Invalid column \"#{columns[index]}\", expected \"#{expected_header}\""
        return
      end
    end
    true
  end

  def process_question(columns)
    row_count = columns[0].to_i
    return unless row_count

    topic = columns[1].to_s
    unless Question::Topics.include? topic
      @failed_upload_questions <<  { :number => row_count, :reason => 'Invalid topic'}
      return
    end

    complexity = columns[2].to_s
    unless Question::Complexities.include? complexity
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid complexity level'}
      return
    end

    statement_body = columns[3].to_s
    if statement.nil? or (statement.to_s.strip.size < 4)
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid question statement'}
      return
    end

    answers_statements = []
    expected_right_answer = ['A', 'B', 'C', 'D', 'E']
    available_answers = []
    4.upto(8) do |index|
      unless columns[index].nil?
        if columns[index].to_s.strip.size > 0
          answers_statements << columns[index]
          available_answers << expected_right_answer.at( index-5)
        end
      end
    end

    if answers_statements.size < 2
      @failed_upload_questions << { :number => row_count, :reason => 'Minimum 2 answers expected'}
      return
    end

    if columns[9].to_s.strip.size < 1
      @failed_upload_questions <<  { :number => row_count, :reason => 'Correct answer missing'}
      return
    end

    correct_answers = columns[9].to_s.upcase.split(',').to_set
    unless correct_answers.subset?(available_answers.to_set)
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid correct answer'}
      return
    end

    objective_options = []
    answers_statements.each do |answer_option|
      objective_options << { :body => answer_option}
    end

    question = Question.new :complexity_list => complexity, :topic_list => topic, :nature_list => 'Objective'
    question.statement = Statement.build :body => statement_body
    question.user_id = @upload_questions_submitter_id
    @question.assign_objective_options objective_options

    

    0.upto(answers_statements.size - 1) do |index|
      answer = question.answers.build
      statement = answers_statements[index]
      # code for displaying values of true and false as it is.
      if (statement.class == Spreadsheet::Formula)
        answer.statement = (statement.value == true) ? 'true' : 'false'
      elsif (statement.class == TrueClass)
        answer.statement = 'true'
      elsif (statement.class == FalseClass)
        answer.statement = 'false'
      else
        answer.statement = statement
      end
      answer.is_right_answer = correct_answers.include?(available_answers[index])? true : false
    end

    if question.save
      @successfuly_upload_questions << row_count
    else
      question.errors.full_messages.each do |error|
        @failed_upload_questions << { :number => row_count, :reason => error}
      end
    end
  end
end

