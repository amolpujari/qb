class CreateTests < ActiveRecord::Migration
  def self.up
    create_table :tests do |t|
      t.string  :title
      t.integer :duration
      
      t.timestamps
    end
    
    create_table :test_topics do |t|
      t.integer :test_id

      t.string  :topic
      t.string  :nature
      t.string  :complexity
      
      t.integer :number_of_questions
      t.integer :marks_for_each_question

      t.timestamps
    end
  end
  
  def self.down
    drop_table :tests
    drop_table :test_topics
  end
end