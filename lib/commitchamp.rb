$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pry'

require 'commitchamp/version'
require 'commitchamp/init_db'
require 'commitchamp/github'

module Commitchamp

  class App

    def initialize
      @github = Github.new(self.login)
    end

    def login
      if ENV['AUTH_TOKEN'] == nil
        result = prompt("What is your Github Token?", "placeholder")
      else
        result = ENV['AUTH_TOKEN']
      end
      result
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

# app = Commitchamp::App.new
# binding.pry
