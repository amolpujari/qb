task :setup => :environment do
  puts 'creating user amol.pujari@gslab.com/amol123...'
  admin = User.new :first_name => "amol",
                   :last_name => "pujari",
                   :email => "amol.pujari@gslab.com"
                      
  admin.password = "amol123"
  admin.save

  puts 'importing few ruby on rails questions....'
  Question.name 
  importer = QuestionImporter.new
  importer.current_user = admin
  importer.process_questions_xls "#{Rails.root.to_s}/db/ror_questions.xlsx"
  puts importer.upload_error
end
