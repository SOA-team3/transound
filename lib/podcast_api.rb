# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require 'tzinfo'
require_relative 'episode'
require_relative 'show'

module TranSound
  # Library for Podcast Web API
  class PodcastApi
    POD_PATH = 'https://api.spotify.com/v1/'

    def initialize(token)
      @spot_token = token
    end

    def episode(type, id, market)
      episode_response = Request.new(POD_PATH, @spot_token).info(type, id, market).parse
      Episode.new(episode_response)
    end

    def show(type, id, market)
      show_response = Request.new(POD_PATH, @spot_token).info(type, id, market).parse
      Show.new(show_response)
    end
  end

  # Sends out HTTP requests to Spotify
  class Request
    def initialize(resource_root, token)
      @resource_root = resource_root
      @token = token
    end

    def info(type, id, market)
      # "https://api.spotify.com/v1/#{type}/#{id}?market=#{market}"
      get(@resource_root + "#{type}/#{id}?market=#{market}")
    end

    def get(url)
      http_response = HTTP.headers(
        'Authorization' => "Bearer #{@token}"
      ).get(url)
      Response.new(http_response).tap do |response|
        raise(response.error) unless response.successful?
      end
    end

    # Decorates HTTP responses with success/error
    class Response < SimpleDelegator
      BadRequest = Class.new(StandardError)
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)
      HTTP_ERROR = {
        400 => BadRequest,
        401 => Unauthorized,
        404 => NotFound
      }.freeze
      def successful?
        !HTTP_ERROR.keys.include?(code)
      end

      def error
        HTTP_ERROR[code]
      end
    end
  end

  # Apply token or Get token
  class Token
    CONFIG = YAML.safe_load_file('../config/secrets.yml')
    CLIENT_ID = CONFIG['spotify_Client_ID']
    CLIENT_SECRET = CONFIG['spotify_Client_secret']
    GETTOKEN_TIME = CONFIG['spotify_gettoken_time']
    TEMP_TOKEN = CONFIG['spotify_temp_token']

    def get
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
      response = HTTP.headers(auth_header).post(token_url, form: params)
      # puts response.body
      json_body = JSON.parse(response.body)
      access_token = json_body['access_token']
      # save the temp token
      save_temp_token(access_token)
      access_token
      # puts "access_token: #{access_token}"
    end

    def save_temp_token(access_token)
      # Modify the value of spotify_gettoken_time and spotify_temp_token
      config = YAML.safe_load_file('../config/secrets.yml')
      config['spotify_gettoken_time'] = current_datetime.strftime('%Y%m%d%H%M%S')
      config['spotify_temp_token'] = access_token
      # Save the updated YAML back to the file
      File.write('../config/secrets.yml', config.to_yaml)
    end

    def current_datetime
      # Create a TZInfo::Timezone object for Taipei, Taiwan
      taipei_timezone = TZInfo::Timezone.get('Asia/Taipei')
      # Get the current time in Taipei
      taipei_timezone.now
    end

    def gettoken_time
      date_time_str = GETTOKEN_TIME
      # Convert the string to a Time object
      Time.strptime(date_time_str, '%Y%m%d%H%M%S')
    end

    def time_difference_of_get_token
      # Calculate the time difference in minutes
      ((current_datetime - gettoken_time) / 60).to_i
    end
  end
end

TYPE = 'episodes'
ID = '7vwvbU1pDkv0IuWPY8SZyz'
MARKET = 'TW'

project = TranSound::PodcastApi.new(TranSound::Token.new.get).episode(TYPE, ID, MARKET)
# puts project.description
# puts TranSound::Request::Response::BadRequest