# frozen_string_literal: true

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'

require_relative '../lib/podcast_api'

# should contain CONST that pass into spec(podcast_info)
EPISODE_TYPE = 'episodes'
SHOW_TYPE = 'shows'
EPISODE_ID = '7vwvbU1pDkv0IuWPY8SZyz'
SHOW_ID = '5Vv32KtHB3peVZ8TeacUty'
MARKET = 'TW'
TEMP_TOKEN = TranSound::Token.new.get
EPISODE_CORRECT = YAML.safe_load_file('spec/fixtures/episode_results.yml')
SHOW_CORRECT = YAML.safe_load_file('spec/fixtures/show_results.yml')

describe 'Episode information' do
  it 'HAPPY: should provide correct episode information' do
    episode = TranSound::PodcastApi.new(TEMP_TOKEN).episode(EPISODE_TYPE, EPISODE_ID, MARKET)
    _(episode.description).must_equal EPISODE_CORRECT['description']
    _(episode.images).must_equal EPISODE_CORRECT['images']
    _(episode.language).must_equal EPISODE_CORRECT['language']
    _(episode.name).must_equal EPISODE_CORRECT['name']
    _(episode.release_date).must_equal EPISODE_CORRECT['release_date']
    _(episode.type).must_equal EPISODE_CORRECT['type']
  end

  it 'SAD: should raise exception on incorrect project' do
    _(proc do
      TranSound::PodcastApi.new(TEMP_TOKEN).episode(EPISODE_TYPE, 'BAD_ID', MARKET)
    end).must_raise TranSound::Request::Response::BadRequest
  end

  it 'SAD: should raise exception when unauthorized' do
    _(proc do
      TranSound::PodcastApi.new('BAD_TOKEN').episode(EPISODE_TYPE, EPISODE_ID, MARKET)
    end).must_raise TranSound::Request::Response::Unauthorized
  end
end

describe 'Show information' do
  it 'HAPPY: should provide correct episode information' do
    show = TranSound::PodcastApi.new(TEMP_TOKEN).show(SHOW_TYPE, SHOW_ID, MARKET)
    _(show.description).must_equal SHOW_CORRECT['description']
    _(show.images).must_equal SHOW_CORRECT['images']
    _(show.name).must_equal SHOW_CORRECT['name']
    _(show.publisher).must_equal SHOW_CORRECT['publisher']
  end

  it 'SAD: should raise exception on incorrect project' do
    _(proc do
      TranSound::PodcastApi.new(TEMP_TOKEN).show(SHOW_TYPE, 'BAD_ID', MARKET)
    end).must_raise TranSound::Request::Response::BadRequest
  end

  it 'SAD: should raise exception when unauthorized' do
    _(proc do
      TranSound::PodcastApi.new('BAD_TOKEN').show(SHOW_TYPE, SHOW_ID, MARKET)
    end).must_raise TranSound::Request::Response::Unauthorized
  end
end
# end
