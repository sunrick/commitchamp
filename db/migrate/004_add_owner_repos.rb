class AddOwnerRepos < ActiveRecord::Migration
  def change
    add_column :repos, :owner, :string
  end
end