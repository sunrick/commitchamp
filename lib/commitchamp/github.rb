require 'httparty'

module Commitchamp
  class Github
    include HTTParty
    base_uri "https://api.github.com"
  end
end
