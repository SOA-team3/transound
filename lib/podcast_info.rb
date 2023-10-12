# frozen_string_literal: true
require 'http'
require 'yaml'
require 'json'

config = YAML.safe_load_file('../config/secrets.yml')
CLIENT_ID = config["spotify_Client_ID"]
CLIENT_SECRET = config["spotify_Client_secret"]


def spotify_api_path(id, category, market)
  "https://api.spotify.com/v1/#{category}/#{id}?market=#{market}"
end

def call_spotify_url(config, url)
  # Bearer token
  token = get_temp_TOKEN
  # Create headers with the Bearer token
  headers = {
    "Authorization" => "Bearer #{token}"
  }
  # Send a GET request
  response = HTTP.headers(headers).get(url)
end

def get_temp_TOKEN
  # Define the URL for the token endpoint
  token_url = "https://accounts.spotify.com/api/token"


  # Define the parameters for the POST request
  params = {
    grant_type: "client_credentials"
  }

  # Set the basic authentication header with your client ID and secret
  auth_header = {
    Authorization: "Basic " + Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")
  }

  # Make the POST request to the token endpoint
  response = HTTP.headers(auth_header)
                .post(token_url, form: params)

  # Print the response
  # puts response.body
  json_body = JSON.parse(response.body)
  access_token = json_body["access_token"]
end
# puts get_temp_TOKEN

podcast_response = {}
podcast_results = {}

## HAPPY project request
project_url = spotify_api_path( id = "7vwvbU1pDkv0IuWPY8SZyz", #"5Vv32KtHB3peVZ8TeacUty",
                                category = "episodes", #could be "episodes" or "shows"
                                market = "TW",)
podcast_response[project_url] = call_spotify_url(config, project_url)
project = podcast_response[project_url].parse

podcast_results['description'] = project['description']
# should be description of some podcast

podcast_results['images'] = project['images']
# should be images of some podcast

podcast_results['name'] = project['name']
# should be name of some podcast

podcast_results['release_date'] = project['release_date']
# should be release_date of some podcast

podcast_results['show'] = project['show']
# should be show of some podcast

podcast_results['type'] = project['type']
# should be type of some podcast


## BAD project request
bad_project_url = spotify_api_path( id = "5Vv32KtHB3peVZ8TeacUtyhjkloihuiopoijkl",
                                    category = "shows",
                                    market = "TW",)
podcast_response[bad_project_url] = call_spotify_url(config, bad_project_url)
# puts podcast_response[bad_project_url].parse # makes sure any streaming finishes

puts podcast_results
File.write('spec/fixtures/podcast_results.yml', podcast_results.to_yaml)
