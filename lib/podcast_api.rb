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
      # The BadRequest class is responsible for Bad ID or other Bad parameters.
      BadRequest = Class.new(StandardError)
      # The Unauthorized class is responsible for Unauthorized Token.
      Unauthorized = Class.new(StandardError)
      # The NotFound class is responsible for API webpage not found.
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
    def initialize
      @secret_path = 'config/secrets.yml'
      @config = YAML.safe_load_file(@secret_path)
    end

    def get
      # puts "Time_difference_of_getting_token: #{TokenTime.time_difference_of_get_token}"
      if TokenTime.new(@config).time_difference_of_get_token >= 55
        access_token = ApplyForNewTempToken.new(@config['spotify_Client_ID'],
                                                @config['spotify_Client_secret']).apply_for_new_temp_token
        # save the temp token
        SaveTempToken.new(@secret_path, @config).save_temp_token(access_token)
        return access_token
      end

      @config['spotify_temp_token']
    end
  end

  # apply for new temp token
  class ApplyForNewTempToken
    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
    end

    # apply for new temp token
    def apply_for_new_temp_token
      # Define the parameters for the POST request
      params = {
        grant_type: 'client_credentials'
      }
      # Set the basic authentication header with your client ID and secret
      auth_header = {
        Authorization: "Basic #{Base64.strict_encode64("#{@client_id}:#{@client_secret}")}"
      }
      # Make the POST request to the token endpoint
      response = HTTP.headers(auth_header).post('https://accounts.spotify.com/api/token', form: params)
      # puts response.body
      json_body = JSON.parse(response.body)
      json_body['access_token']
    end
  end

  # this can save temp token to secrets.yml
  class SaveTempToken
    def initialize(secret_path, config)
      @secret_path = secret_path
      @config = config
      @taipei_timezone = TZInfo::Timezone.get('Asia/Taipei')
    end

    def save_temp_token(access_token)
      # Modify the value of spotify_gettoken_time and spotify_temp_token
      @config['spotify_gettoken_time'] = @taipei_timezone.now.strftime('%Y%m%d%H%M%S')
      @config['spotify_temp_token'] = access_token
      # Save the updated YAML back to the file
      File.write(@secret_path, @config.to_yaml)
    end
  end

  # record token time in taipei time
  class TokenTime
    def initialize(config)
      @config = config
      @gettoken_time = @config['spotify_gettoken_time']
      @taipei_timezone = TZInfo::Timezone.get('Asia/Taipei')
    end

    # get token time
    def gettoken_time
      date_time_str = @gettoken_time
      # Convert the string to a Time object
      Time.strptime(date_time_str, '%Y%m%d%H%M%S')
    end

    def time_difference_of_get_token
      # Calculate the time difference in minutes
      ((@taipei_timezone.now - gettoken_time) / 60).to_i
    end
  end
end

# TYPE = 'episodes'
# ID = '7vwvbU1pDkv0IuWPY8SZyz'
# MARKET = 'TW'
# TEMP_TOKEN = TranSound::Token.new.get

# project = TranSound::PodcastApi.new( TEMP_TOKEN ).episode(TYPE, ID, MARKET)
# puts project.description
# puts TranSound::Request::Response::BadRequest

# TYPE = 'shows'
# ID = '5Vv32KtHB3peVZ8TeacUty'
# MARKET = 'TW'

# show = TranSound::PodcastApi.new(TranSound::Token.new.get).episode(TYPE, ID, MARKET)
# # puts show.description
