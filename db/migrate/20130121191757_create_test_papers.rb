class CreateTestPapers < ActiveRecord::Migration
  def self.change
    create_table :test_papers do |t|
      t.integer  :candidate_id
      t.column   :status, "ENUM('new', 'completed', 'in_progress') DEFAULT 'new' NOT NULL"
      t.integer  :duration_left_in_minutes
      t.timestamps
    end

    add_index :test_papers, :candidate_id

    create_table :test_paper_questions do |t|
      t.integer  :test_paper_id
      t.integer  :question_id
      t.integer  :candidate_objective_answer_id
      t.text     :candidate_subjective_answer_statement
      t.boolean  :marked_for_revisit, :default => false
      t.timestamps
    end

    add_index :test_paper_questions, :test_paper_id

    create_table :test_paper_results do |t|
      t.integer  :test_paper_id
      t.integer  :objective_score, :default => 0
      t.integer  :subjective_score, :default => 0
      t.timestamps
    end

    add_index :test_paper_results, :test_paper_id
  end
end