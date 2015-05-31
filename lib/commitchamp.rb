$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pry'

require 'commitchamp/version'
require 'commitchamp/init_db'
require 'commitchamp/github'
require 'commitchamp/user'
require 'commitchamp/repo'
require 'commitchamp/contribution'

module Commitchamp

  class App

    def initialize
      @github = Github.new(self.login)
    end

    def login
      if ENV['AUTH_TOKEN'] == nil
        result = prompt("What is your Github Token?", /^\w{40}$/)
      else
        result = ENV['AUTH_TOKEN']
      end
      result
    end

    def get_org_repos
      result = {}
      org = prompt("What organization do you want?", /^\w+$/)
      repos = @github.get_repos(org)
      repos.each do |repo|
        result = {
          owner: repo['owner']['login'],
          name: repo['name'],
          description: repo['description'],
          fork: repo['fork'],
          forks_count: repo['forks_count'],
          stargazers_count: repo['stargazers_count'],
          watches_count: repo['watchers_count'],
          github_id: repo['id'].to_i
        }
        create_repo(result)
      end
    end

    def create_repo(repo_hash)
      github_id = repo_hash[:github_id]
      if Repo.exists?(github_id: github_id)
        Repo.find_by(github_id: github_id).update(repo_hash)
      else
        Repo.create(repo_hash)
      end
    end

    def prompt(question, validator)
      puts question
      result = gets.chomp
      until result =~ validator
        puts question
        result = gets.chomp
      end
      result
    end

  end

end

app = Commitchamp::App.new
binding.pry
