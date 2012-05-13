class CreateStatements < ActiveRecord::Migration
  def self.up
    create_table :statements do |t|
      t.text :body

      t.integer :user_id

      t.references :statement_for, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :statements
  end
end
