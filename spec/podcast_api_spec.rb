# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'

require 'yaml'
require_relative '../lib/podcast_api'

EPISODE_TYPE = 'episodes'
SHOW_TYPE = 'shows'
EPISODE_ID = '7vwvbU1pDkv0IuWPY8SZyz'
SHOW_ID = '5Vv32KtHB3peVZ8TeacUty'
MARKET = 'TW'
TEMP_TOKEN = TranSound::Token.new.get
CORRECT = YAML.safe_load(File.read('fixtures/podcast_results.yml'))

describe 'Tests Podcast API library' do
  describe 'Episode information' do
    it 'HAPPY: should provide correct episode information' do
      episode = TranSound::PodcastApi.new(TEMP_TOKEN).episode(EPISODE_TYPE, EPISODE_ID, MARKET)
      _(episode.description).must_equal CORRECT['description']
      _(episode.images).must_equal CORRECT['images']
      _(episode.language).must_equal CORRECT['language']
      _(episode.name).must_equal CORRECT['name']
      _(episode.release_date).must_equal CORRECT['release_date']
      _(episode.type).must_equal CORRECT['type']
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
      _(show.description).must_equal CORRECT['description']
      _(show.images).must_equal CORRECT['images']
      _(show.name).must_equal CORRECT['name']
      _(show.publisher).must_equal CORRECT['publisher']
    end

    it 'SAD: should raise exception on incorrect project' do
      _(proc do
        TranSound::PodcastApi.new(TEMP_TOKEN).show(SHOW_TYPE, 'BAD_ID', MARKET)
      end).must_raise TranSound::Request::Response::BadRequest
      # .must_raise TranSound::Request::Response::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        TranSound::PodcastApi.new('BAD_TOKEN').show(SHOW_TYPE, SHOW_ID, MARKET)
      end).must_raise TranSound::Request::Response::Unauthorized
    end
  end
end