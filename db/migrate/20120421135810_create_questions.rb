class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.boolean :delta, :default => true, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
