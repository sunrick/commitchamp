class RemoveUserColumn < ActiveRecord::Migration
  def change
    remove_column :repos, :user_id
  end
end