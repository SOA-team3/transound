# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/podcast_api'

# should contain CONST that pass into spec(podcast_info)
EPISODE_TYPE = 'episodes'
SHOW_TYPE = 'shows'
EPISODE_ID = '7vwvbU1pDkv0IuWPY8SZyz'
SHOW_ID = '5Vv32KtHB3peVZ8TeacUty'
MARKET = 'TW'

<<<<<<< HEAD
TEMP_TOKEN = TranSound::Token.new.get
=======
SECRET_PATH = 'config/secrets.yml'
CONFIG = YAML.safe_load_file(SECRET_PATH)
CLIENT_ID = CONFIG['spotify_Client_ID']
CLIENT_SECRET = CONFIG['spotify_Client_secret']
TEMP_TOKEN = TranSound::Token.new(SECRET_PATH, CONFIG, CLIENT_ID, CLIENT_SECRET).get
>>>>>>> d95923cd2933a3439743f7751fc38040e1ec50fa
EPISODE_CORRECT = YAML.safe_load_file('spec/fixtures/episode_results.yml')
SHOW_CORRECT = YAML.safe_load_file('spec/fixtures/show_results.yml')

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'podcast_api[.yml]'
