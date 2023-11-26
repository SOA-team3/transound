# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

require 'ostruct'

describe 'ViewEpisodeService Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_podcast(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'View a Episode' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return episodes that are being watched' do
      # GIVEN: a valid episodeexists locally and is being watched
      pd_episode= TranSound::Episode::EpisodeMapper
      .new(TEMP_TOKEN)
      .find(EPISODE_TYPE, EPISODE_ID)
      db_episode= TranSound::Repository::For.entity(pd_episode)
        .create(pd_episode)

      watched_list = ["#{EPISODE_TYPE}/#{EPISODE_ID}"]
      # WHEN: we request a list of all watched episodes
      result = TranSound::Service::ListEpisodes.new.call(watched_list)

      # THEN: we should see our episode in the resulting list
      _(result.success?).must_equal true
      episodes = result.value!
      _(episodes).must_include db_episode
    end

    it 'HAPPY: should not return episodes that are not being watched' do
      # GIVEN: a valid episodeexists locally but is not being watched
      pd_episode= TranSound::Github::EpisodeMapper
        .new(GITHUB_TOKEN)
        .find(EPISODE_TYPE, EPISODE_ID)
        TranSound::Repository::For.entity(pd_episode)
        .create(pd_episode)

      watched_list = []

      # WHEN: we request a list of all watched episodes
      result = TranSound::Service::ListEpisodes.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      episodes = result.value!
      _(episodes).must_equal []
    end

    it 'SAD: should not watched episodes if they are not loaded' do
      # GIVEN: we are watching a episodethat does not exist locally
      watched_list = ["#{EPISODE_TYPE}/#{EPISODE_ID}"]
      # WHEN: we request a list of all watched episodes
      result = TranSound::Service::ListEpisodes.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      episodes = result.value!
      _(episodes).must_equal []
    end
  end
end

describe 'ViewShowService Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_podcast(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'View a Show' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return shows that are being watched' do
      # GIVEN: a valid showexists locally and is being watched
      pd_show= TranSound::Show::ShowMapper
      .new(TEMP_TOKEN)
      .find(SHOW_TYPE, SHOW_ID)
      db_show= TranSound::Repository::For.entity(pd_show)
        .create(pd_show)

      watched_list = ["#{SHOW_TYPE}/#{SHOW_ID}"]
      # WHEN: we request a list of all watched shows
      result = TranSound::Service::ListShows.new.call(watched_list)

      # THEN: we should see our show in the resulting list
      _(result.success?).must_equal true
      shows = result.value!
      _(shows).must_include db_show
    end

    it 'HAPPY: should not return shows that are not being watched' do
      # GIVEN: a valid showexists locally but is not being watched
      pd_show= TranSound::Github::ShowMapper
        .new(GITHUB_TOKEN)
        .find(SHOW_TYPE, SHOW_ID)
        TranSound::Repository::For.entity(pd_show)
        .create(pd_show)

      watched_list = []

      # WHEN: we request a list of all watched shows
      result = TranSound::Service::ListShows.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      shows = result.value!
      _(shows).must_equal []
    end

    it 'SAD: should not watched shows if they are not loaded' do
      # GIVEN: we are watching a showthat does not exist locally
      watched_list = ["#{SHOW_TYPE}/#{SHOW_ID}"]

      # WHEN: we request a list of all watched shows
      result = TranSound::Service::ListShows.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      shows = result.value!
      _(shows).must_equal []
    end
  end
end