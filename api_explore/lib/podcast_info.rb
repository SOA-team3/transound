# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require 'tzinfo' # for calculate time in certain district

config = YAML.safe_load_file('../config/secrets.yml')
CLIENT_ID = config['spotify_Client_ID']
CLIENT_SECRET = config['spotify_Client_secret']
GETTOKEN_TIME = config['spotify_gettoken_time']
TEMP_TOKEN = config['spotify_temp_token']

def spotify_api_path(id, type, market)
  "https://api.spotify.com/v1/#{type}/#{id}?market=#{market}"
end

def call_spotify_url(_config, url)
  # Bearer token
  token = get_temp_token

  # Create headers with the Bearer token
  headers = {
    'Authorization' => "Bearer #{token}"
  }
  # Send a GET request
  HTTP.headers(headers).get(url)
end

def get_temp_token
  return apply_for_new_temp_token if time_difference_of_get_token >= 55

  TEMP_TOKEN
end

def apply_for_new_temp_token
  # Define the URL for the token endpoint
  token_url = 'https://accounts.spotify.com/api/token'
  # Define the parameters for the POST request
  params = {
    grant_type: 'client_credentials'
  }
  # Set the basic authentication header with your client ID and secret
  auth_header = {
    Authorization: "Basic #{Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")}"
  }
  # Make the POST request to the token endpoint
  response = HTTP.headers(auth_header)
                 .post(token_url, form: params)
  # puts response.body
  json_body = JSON.parse(response.body)
  access_token = json_body['access_token']
  #save the temp token
  save_temp_token(access_token)
  access_token
  # puts "access_token: #{access_token}"
end

def save_temp_token(access_token)
  # Modify the value of spotify_gettoken_time and spotify_temp_token
  config = YAML.safe_load_file('../config/secrets.yml')
  config['spotify_gettoken_time'] = get_current_datetime.strftime('%Y%m%d%H%M%S')
  config['spotify_temp_token'] = access_token
  # Save the updated YAML back to the file
  File.write('../config/secrets.yml', config.to_yaml)
end

def get_current_datetime
  # Create a TZInfo::Timezone object for Taipei, Taiwan
  taipei_timezone = TZInfo::Timezone.get('Asia/Taipei')
  # Get the current time in Taipei
  taipei_timezone.now
end

def get_token_time
  date_time_str = GETTOKEN_TIME
  # Convert the string to a Time object
  Time.strptime(date_time_str, '%Y%m%d%H%M%S')
end

def time_difference_of_get_token
  # puts get_current_datetime
  # puts get_token_time

  # Calculate the time difference in minutes
  ((get_current_datetime - get_token_time) / 60).to_i
end

podcast_response = {}
podcast_results = {}

# ## HAPPY project request
project_url = spotify_api_path(id = '7vwvbU1pDkv0IuWPY8SZyz', # "5Vv32KtHB3peVZ8TeacUty",
                               type = 'episodes', # could be "episodes" or "shows"
                               market = 'TW')
podcast_response[project_url] = call_spotify_url(config, project_url)
project = podcast_response[project_url].parse

podcast_results['description'] = project['description']
# should be the description of a certain podcast

podcast_results['images'] = project['images']
# should be the images of a certain podcast

podcast_results['name'] = project['name']
# should be the name of a certain podcast

podcast_results['release_date'] = project['release_date']
# should be the release_date of a certain podcast

# .slice to remain keys that we want
keep_keys = %w[description images name publisher]
show_hash = project['show'].slice(*keep_keys)
podcast_results['show'] = show_hash
# should be the show-content of a certain podcast

podcast_results['type'] = project['type']
# should be the type of a certain podcast

## BAD project request
bad_project_url = spotify_api_path(id = '5eacUtyhjkloihuiopoijkl',
                                   type = 'shows',
                                   market = 'TW')
podcast_response[bad_project_url] = call_spotify_url(config, bad_project_url)
# puts podcast_response[bad_project_url].parse # makes sure any streaming finishes

# puts podcast_results
File.write('spec/fixtures/podcast_results.yml', podcast_results.to_yaml)
