class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.boolean :delta, :default => true, :null => false
      t.text :statement
      t.integer :submitter_id
      t.timestamps
    end
  end
end
