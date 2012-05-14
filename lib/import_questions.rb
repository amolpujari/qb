include Spreadsheet
require 'set'

module ImportQuestions
  MIN_SIZE = 7168          #7Kb
  MAX_SIZE = 10485760      #10Mb
  
  def questions_uploaded_successfuly_from file
    @upload_questions_submitter_id = current_user.id
    @upload_questions_moderator_id = nil
    @upload_questions_status = 'moderated'

    if file.blank?
      @upload_error = 'Invalid file'
      return false
    end
    
    if not (File.extname(file.original_filename).eql? '.xls')
      @upload_error = 'Invalid file'
      return false
    end

    file_path = save_file_on_disk file

    if File.size(file_path) < MIN_SIZE
      @upload_error = 'Blank file'
      File.delete file_path rescue nil
      return false
    end

    if File.size(file_path) > MAX_SIZE
      @upload_error = 'File size too large, allowed upto 10 MB only'
      File.delete file_path rescue nil
      return false
    end
    
    if not process_questions_xls file_path
      File.delete file_path rescue nil
      return false
    end
    
    File.delete file_path rescue nil
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
      return nil
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
      return nil
    end

    first_sheet.each_with_index do | columns, row|
      if row == 0
        return nil if not header_checks_ok? columns
      else
        process_question columns
      end
    end
  end

  def header_checks_ok? columns
    if columns.size < 11
      @upload_error = '11 header columns expected'
      return false
    end

    expected_headers = ['No.','Subject','Topic','Difficulty Level','Question','A','B','C','D','E','Correct Answers']

    expected_headers.each_with_index do |expected_header, index|
      if not ( columns[index].casecmp(expected_header) == 0)
        @upload_error = "Invalid column \"#{columns[index]}\", expected \"#{expected_header}\""
        return false
      end
    end
    true
  end

  def process_question(columns)
    row_count = columns[0].to_i rescue nil
    return unless row_count

    if columns[1].nil? or (columns[1].to_s.strip.size < 1)
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid subject'}
      return
    end
    subject = Subject.find_or_create(:name => columns[1].to_s)

    if columns[2].nil? or (columns[2].to_s.strip.size < 1)
      @failed_upload_questions <<  { :number => row_count, :reason => 'Invalid topic'}
      return
    end
    topic = Topic.find_or_create(:name => columns[2].to_s, :subject_id => subject.id)

    question_category = QuestionCategory.find_by_name columns[3] rescue nil
    if not question_category
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid difficulty level'}
      return
    end

    if columns[4].nil? or (columns[4].to_s.strip.size < 4)
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid question statement'}
      return
    end

    answers_statements = []
    expected_right_answer = ['A', 'B', 'C', 'D', 'E']
    available_answers = []
    5.upto(9) do |index|
      if not columns[index].nil?
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

    if columns[10].to_s.strip.size < 1
      @failed_upload_questions <<  { :number => row_count, :reason => 'Correct answer missing'}
      return
    end

    correct_answers = columns[10].to_s.upcase.split(',').to_set
    if not correct_answers.subset?(available_answers.to_set)
      @failed_upload_questions << { :number => row_count, :reason => 'Invalid correct answer'}
      return
    end

    question = Question.new(:statement => columns[4].to_s,
      :question_category_id => question_category.id,
      :subject_id => subject.id,
      :topic_id => topic.id,
      :submitter_id => @upload_questions_submitter_id,
      :moderator_id => @upload_questions_moderator_id,
      :status => @upload_questions_status
    )

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

