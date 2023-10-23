# frozen_string_literal: true

require 'roda'
require 'yaml'

# get TranSound::Token class
require_relative '../app/models/gateways/podcast_api'

SECRET_PATH = 'config/secrets.yml'
CONFIG = YAML.safe_load_file(SECRET_PATH)
CLIENT_ID = CONFIG['spotify_Client_ID']
CLIENT_SECRET = CONFIG['spotify_Client_secret']

module TranSound
  # Configuration for the App
  class App < Roda
    TEMP_TOKEN = TranSound::Podcast::Api::Token.new(SECRET_PATH, CONFIG, CLIENT_ID, CLIENT_SECRET).get
    puts "environment.rb: #{TEMP_TOKEN}"
  end
end
