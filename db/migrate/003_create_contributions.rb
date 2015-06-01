class CreateContributions < ActiveRecord::Migration

  def change
    create_table :contributions do |t|
      t.integer :additions
      t.integer :deletions
      t.integer :commits
      t.integer :user_id
      t.integer :repo_id
    end
  end
  
end