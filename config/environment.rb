# frozen_string_literal: true

require 'figaro'
require 'roda'
require 'sequel'
require 'yaml'

# get TranSound::Token class
require_relative '../app/infrastructure/gateways/podcast_api'

SECRET_PATH = 'config/secrets.yml'
CONFIG = YAML.safe_load_file(SECRET_PATH)
CLIENT_ID = CONFIG['test']['spotify_Client_ID']
CLIENT_SECRET = CONFIG['test']['spotify_Client_secret']
puts "CONFIG: #{CONFIG}"
puts "CLIENT_SECRET: #{CLIENT_SECRET}"

module TranSound
  # Configuration for the App
  class App < Roda
    TEMP_TOKEN = TranSound::Podcast::Api::Token.new(SECRET_PATH, CONFIG, CLIENT_ID, CLIENT_SECRET).get
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment:,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      # Database Setup
      @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
      def self.db = @db # rubocop:disable Style/TrivialAccessors
    end
  end
end
