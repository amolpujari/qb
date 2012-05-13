class CreateObjectiveOptions < ActiveRecord::Migration
  def self.up
    create_table :objective_options do |t|
      t.text    :body
      t.integer :question_id
      t.boolean :is_correct,  :null => false, :default => false
    end
  end

  def self.down
    drop_table :objective_options
  end
end
