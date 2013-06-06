class CreateTestPapers < ActiveRecord::Migration
  def change
    create_table :test_papers do |t|
      t.integer    :created_by
      t.string     :summary
      t.string     :pin
      t.integer    :candidate_id
      t.integer    :minutes_left
      t.integer    :objective_score, :default => 0
      t.datetime   :started_at
      t.datetime   :ended_at
      t.string     :status, :default => 'scheduled'
      t.timestamps
    end

    create_table :test_paper_questions do |t|
      t.integer    :test_paper_id
      t.integer    :question_id
      t.integer    :given_answer_id
      t.boolean    :marked_for_revisit, :default => false
    end
  end
end