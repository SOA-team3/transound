# frozen_string_literal: true

require 'http'
require_relative 'episode'
require_relative 'show'

require 'yaml'
CONFIG = YAML.safe_load_file('../config/secrets.yml')
CLIENT_ID = CONFIG['spotify_Client_ID']
CLIENT_SECRET = CONFIG['spotify_Client_secret']
GETTOKEN_TIME = CONFIG['spotify_gettoken_time']
TEMP_TOKEN = CONFIG['spotify_temp_token']

TYPE = "episodes"
ID = "7vwvbU1pDkv0IuWPY8SZyz"
MARKET = "TW"

module TranSound
  # Library for Podcast Web API
  class PodcastApi
    POD_PATH = "https://api.spotify.com/v1/".freeze

    def initialize(token)
      @spot_token = token
    end

    def episode(type, id, market)
      episode_response = Request.new(POD_PATH, @spot_token).repo(type, id, market).parse
      Episode.new(episode_response)
    end

    def show(type, id, market)
      show_response = Request.new(POD_PATH, @spot_token).repo(type, id, market).parse
      Show.new(show_response)
    end
  end

  # Sends out HTTP requests to Spotify
  class Request
    def initialize(resource_root, token)
      @resource_root = resource_root
      @token = token
    end

    def repo(type, id, market)
      #"https://api.spotify.com/v1/#{type}/#{id}?market=#{market}"
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
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)
      HTTP_ERROR = {
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

end

project = TranSound::PodcastApi.new(TEMP_TOKEN).episode(TYPE, ID, MARKET)
puts project.description