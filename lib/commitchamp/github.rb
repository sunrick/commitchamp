require 'httparty'

module Commitchamp
  class Github
    include HTTParty
    base_uri "https://api.github.com"

    def initialize(token)
      @headers = { "Authorization" => "token #{token}",
                  "User-Agent" => "HTTParty" }
    end

    def get_contributions(owner, repo, page=1)
      params = {
        page: page
      }
      options = {
        headers: @headers,
        query: params
      }
      Github.get("/repos/#{owner}/#{repo}/stats/contributors", options)
    end

    def get_repos(org, page=1)
      params = {
        page: page
      }
      options = {
        headers: @headers,
        query: params
      }
      Github.get("/orgs/#{org}/repos", options)
    end

  end
end
