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

    def get_org_repos(org)
      page = 1
      repos = @github.get_repos(org, page)
      while repos.length == 30
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
          self.create_repo(result)
        end
        page += 1
        repos = @github.get_repos(org, page)
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

    def get_repo_contributions(org, repo)
      contributions = @github.get_contributions(org, repo)
      contributions.each do |contrib|
        weeks = contrib['weeks']
        result = {
          additions: self.get_sum(weeks, 'a'),
          deletions: self.get_sum(weeks, 'd'),
          commits: contrib['total'],
          user_id: create_user(contrib['author']['login']),
          repo_id: Repo.find_by(name: repo).id
        }
        self.create_contribution(result)
      end
    end

    def get_sum(weeks, data_type)
      result = []
      if weeks != nil
        weeks.each do |week|
          result << week[data_type]
        end
      result = result.sum
      end
    end

    def create_contribution(contrib_hash)
      user_id = contrib_hash[:user_id]
      repo_id = contrib_hash[:repo_id]
      if Contribution.exists?({user_id: user_id, repo_id: repo_id})
        Contribution.find_by(user_id: user_id, repo_id: repo_id).update(contrib_hash)
      else
        Contribution.create(contrib_hash)
      end
    end

    def create_user(login)
      user = User.find_or_create_by(login: login)
      result = user.id
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

    def run
      input = self.prompt("Do you want to fetch new data (f) or look at existing data (d)?", /^[fd]$/i)
      org = self.prompt("What organization do you want?", /^\w+$/).downcase
      if input.downcase == "f"
        self.fetch(org)
        self.analyze(org)
      else
        no_data?(org)
        self.analyze(org)
      end
    end

    def fetch(org)
      self.get_org_repos(org)
      repos = Repo.where(owner: org).all
      repos.each do |repo|
        self.get_repo_contributions(org, repo.name)
      end
    end

    def analyze(org)
      puts "What repo do you want? Please enter integer"
      available = Repo.where(owner: org)
      available.each do |x|
        puts "#{x.id} | #{x.name}"
      end
      repo_id = gets.chomp.to_i
      self.display_info(repo_id)
    end

    def display_info(repo_id)
      repo = Repo.find(repo_id)
      top_contributors = repo.contributions.order('additions + deletions DESC').limit(10)
      puts "\nContributions for #{repo.name} in the #{repo.owner} organization!"
      puts "\nGithub User - Additions - Deletions - Commits\n"
      top_contributors.each do |contributor|
        puts "#{contributor.user.login} - #{contributor.additions} - #{contributor.deletions} - #{contributor.commits}"
      end
    end

    def no_data?(org)
      unless Repo.exists?(owner: org)
        puts "Sorry, I don't have that data, will fetch it for you..."
        self.fetch(org)
      end
    end

  end

end

app = Commitchamp::App.new
app.run
