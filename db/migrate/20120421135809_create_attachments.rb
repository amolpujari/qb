class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.references :attachable, :polymorphic => true

      t.timestamps
    end

    add_index 'attachments', :attachable_id

    add_column :attachments, :upload_file_name, :string
    add_column :attachments, :upload_content_type, :string
    add_column :attachments, :upload_file_size, :integer
    add_column :attachments, :upload_updated_at, :datetime
  end
end
