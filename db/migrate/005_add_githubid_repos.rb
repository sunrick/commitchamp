class AddGithubidRepos < ActiveRecord::Migration
  def change
    add_column :repos, :github_id, :integer
  end
end