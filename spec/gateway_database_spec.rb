# frozen_string_literal: false

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Github API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_github
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store episode' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save *episode* from Spotify to database' do
      episode = TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find(EPISODE_TYPE, EPISODE_ID, MARKET)

      rebuilt = TranSound::Repository::For.entity(episode).create(episode)

      _(rebuilt.origin_id).must_equal(episode.origin_id)
      _(rebuilt.name).must_equal(episode.name)
      _(rebuilt.description).must_equal(episode.description)
      _(rebuilt.images).must_equal(episode.images)
      _(rebuilt.language).must_equal(episode.language)
      _(rebuilt.release_date).must_equal(episode.release_date)
    end
  end
end