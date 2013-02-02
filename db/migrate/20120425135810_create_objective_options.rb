class CreateObjectiveOptions < ActiveRecord::Migration
  def change
    create_table :objective_options do |t|
      t.text    :statement
      t.integer :question_id
      t.boolean :is_correct,  :null => false, :default => false
    end
  end
end
