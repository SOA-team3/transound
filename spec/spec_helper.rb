# frozen_string_literal: true

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
TEMP_TOKEN = TranSound::Token.new.get
EPISODE_CORRECT = YAML.safe_load_file('fixtures/episode_results.yml')
SHOW_CORRECT = YAML.safe_load_file('fixtures/show_results.yml')

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'github_api'