require 'rubyXL'

class QuestionImporter
  MIN_SIZE = 7168          #7Kb
  MAX_SIZE = 10485760      #10Mb
  
  def initialize file
    #@upload_questions_moderator_id = nil
    #@upload_questions_status = 'moderated'

    if file.blank?
      @upload_error = 'Blank file'
      return
    end
    
    unless (File.extname(file.original_filename).eql? '.xlsx')
      @upload_error = 'Invalid file'
      return
    end

    file_path = save_file_on_disk file
    return unless file_path

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
    
    unless process_questions_xls file_path
      File.delete file_path
      return
    end
    
    File.delete file_path

    result
  end

  def result
    [@upload_error, @failed_upload_questions, @successfuly_upload_questions]
  end

  private

  def save_file_on_disk(file)
    begin
      input_path = Rails.root.join("tmp/imported_questions_files/").to_s
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
      xlsx = RubyXL::Parser.parse file_path
      first_sheet = xlsx[0].extract_data
    rescue Exception => e
      @upload_error = 'Does not seem to be a valid xlsx.'
      puts "  upload error: #{e.message}"
      return
    end

    return unless header_checks_ok? first_sheet[0]

    first_sheet[1..-1].each do | row|
      process_question row
    end
  end

  def header_checks_ok? columns
    if columns.size < 10
      @upload_error = '10 header columns expected'
      return
    end

    expected_headers = ['S. No.', 'Topic', 'Complexity Level', 'Question','Answer A','Answer B','Answer C','Answer D','Answer E','Correct Answer']

    expected_headers.each_with_index do |expected_header, index|
      unless ( columns[index].casecmp(expected_header) == 0)
        @upload_error = "Invalid column \"#{columns[index]}\", expected \"#{expected_header}\""
        return
      end
    end
    
    true
  end

  def process_question(columns)
    row_count = columns[0].to_i
    return unless row_count
    return if row_count < 1

    topic = columns[1].to_s.strip
    if topic.length < 2
      @failed_upload_questions <<  { :number => row_count, :reason => 'Invalid topic'}
      return
    end

    #    unless Question::Topics.include? topic
    #      @failed_upload_questions <<  { :number => row_count, :reason => 'Invalid topic'}
    #      return
    #    end

    complexity = columns[2].to_s.strip
    if complexity.length < 2
      @failed_upload_questions <<  { :number => row_count, :reason => 'Invalid topic'}
      return
    end
    
    #    unless Question::Complexities.include? complexity
    #      @failed_upload_questions << { :number => row_count, :reason => 'Invalid complexity level'}
    #      return
    #    end
    
    statement_body = columns[3].to_s
    if statement_body.nil? or (statement_body.to_s.strip.size < 4)
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
          available_answers << expected_right_answer.at( index-4)
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
    answers_statements.each_with_index do |answer_option, index|

      #      if (answer_option.class == Spreadsheet::Formula)
      #        body = (answer_option.value == true) ? 'true' : 'false'
      #      elsif (answer_option.class == TrueClass)
      #        body = 'true'
      #      elsif (answer_option.class == FalseClass)
      #        body = 'false'
      #      else
      #        body = answer_option
      #      end
      body = answer_option

      is_correct = correct_answers.include? available_answers[index]

      objective_options << { :body => body, :is_correct => is_correct}
    end

    question = Question.new :complexity_list => complexity, :topic_list => topic, :nature_list => 'Objective'
    question.statement = Statement.new :body => statement_body
    question.statement.user = current_user
    question.assign_objective_options objective_options

    if question.save
      @successfuly_upload_questions << row_count
    else
      question.errors.full_messages.each do |error|
        @failed_upload_questions << { :number => row_count, :reason => error}
      end
    end
  end
end

