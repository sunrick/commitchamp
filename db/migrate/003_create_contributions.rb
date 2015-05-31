class CreateContributions < ActiveRecord::Migration

  def change
    create_table :contributions do |t|
      t.integer :additions
      t.integer :deletions
      t.integer :commits
      t.belongs_to :user
      t.belongs_to :repo_id
    end
  end
  
end