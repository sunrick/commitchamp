class CreateRepos < ActiveRecord::Migration

  def change
    create_table :repos do |t|
      t.string :name
      t.string :description
      t.boolean :fork
      t.integer :forks_count
      t.integer :stargazers_count
      t.integer :watches_count
      t.belongs_to :user
    end
  end
  
end