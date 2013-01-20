class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :first_name, :null => false
      t.string :last_name,  :null => false

      t.string :email,      :null => false
      t.timestamps
    end

    add_index :candidates, :email
  end
end
