# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

require 'ostruct'

describe 'ViewEpisode Service Integration Test' do
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

    it 'HAPPY: should give episodes for a folder of an existing episode' do
      # GIVEN: a valid episode that exists locally and is being watched
      pd_episode= TranSound::Episode::EpisodeMapper
        .new(TEMP_TOKEN)
        .find(EPISODE_TYPE, EPISODE_ID)
        TranSound::Repository::For.entity(pd_episode).create(pd_episode)

      # WHEN: we request to view the episode
      request = OpenStruct.new(
        type: EPISODE_TYPE,
        origin_id: EPISODE_ID,
        episode_fullname: "#{EPISODE_TYPE}/#{EPISODE_ID}",
        folder_name: ''
      )

      appraisal = TranSound::Service::ViewEpisode.new.call(
        watched_list: [request.episode_fullname],
        requested: request
      ).value!

      # THEN: we should get an appraisal
      _(%i[episode folder] & appraisal.keys).must_equal %i[episode folder]
      folder = appraisal[:folder]
      _(folder).must_be_kind_of TranSound::Entity::AudioDownloader
      _(folder.subfolders.count).must_equal 10
      _(folder.base_files.count).must_equal 2

      _(folder.base_files.first.file_path.filename).must_equal 'README.md'
      _(folder.subfolders.first.path).must_equal 'controllers'

      _(folder.subfolders.map(&:credit_share).reduce(&:+) +
        folder.base_files.map(&:credit_share).reduce(&:+))
        .must_equal(folder.credit_share)
    end

    it 'SAD: should not give contributions for an unwatched episode' do
      # GIVEN: a valid episode that exists locally and is being watched
      pd_episode = TranSound::Episode::EpisodeMapper
        .new(TEMP_TOKEN)
        .find(EPISODE_TYPE, EPISODE_ID)
      TranSound::Repository::For.entity(pd_episode).create(pd_episode)

      # WHEN: we request to view the episode
      request = OpenStruct.new(
        type: EPISODE_TYPE,
        origin_id: EPISODE_ID,
        episode_fullname: "#{EPISODE_TYPE}/#{EPISODE_ID}",
        folder_name: ''
      )

      result = TranSound::Service::ViewEpisode.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end

    it 'SAD: should not give contributions for non-existent episode' do
      # GIVEN: no episode exists locally

      # WHEN: we request to view the episode
      request = OpenStruct.new(
        type: EPISODE_TYPE,
        origin_id: EPISODE_ID,
        episode_fullname: "#{EPISODE_TYPE}/#{EPISODE_ID}",
        folder_name: ''
      )

      result = TranSound::Service::ViewEpisode.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end
  end
end

describe 'ViewShow Service Integration Test' do
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

    it 'HAPPY: should give contributions for a folder of an existing show' do
      # GIVEN: a valid show that exists locally and is being watched
      pd_show= TranSound::Github::ShowMapper
        .new(GITHUB_TOKEN)
        .find(SHOW_TYPE, SHOW_ID)
      TranSound::Repository::For.entity(pd_show).create(pd_show)

      # WHEN: we request to view the show
      request = OpenStruct.new(
        type: SHOW_TYPE,
        origin_id: SHOW_ID,
        show_fullname: "#{SHOW_TYPE}/#{SHOW_ID}",
        folder_name: ''
      )

      appraisal = TranSound::Service::ViewShow.new.call(
        watched_list: [request.show_fullname],
        requested: request
      ).value!

      # THEN: we should get an appraisal
      _(%i[show folder] & appraisal.keys).must_equal %i[show folder]
      folder = appraisal[:folder]
      _(folder).must_be_kind_of TranSound::Entity::AudioDownloader
      _(folder.subfolders.count).must_equal 10
      _(folder.base_files.count).must_equal 2

      _(folder.base_files.first.file_path.filename).must_equal 'README.md'
      _(folder.subfolders.first.path).must_equal 'controllers'

      _(folder.subfolders.map(&:credit_share).reduce(&:+) +
        folder.base_files.map(&:credit_share).reduce(&:+))
        .must_equal(folder.credit_share)
    end

    it 'SAD: should not give contributions for an unwatched show' do
      # GIVEN: a valid show that exists locally and is being watched
      pd_show= TranSound::Github::ShowMapper
        .new(GITHUB_TOKEN)
        .find(SHOW_TYPE, SHOW_ID)
      TranSound::Repository::For.entity(pd_show).create(pd_show)

      # WHEN: we request to view the show
      request = OpenStruct.new(
        type: SHOW_TYPE,
        origin_id: SHOW_ID,
        show_fullname: "#{SHOW_TYPE}/#{SHOW_ID}",
        folder_name: ''
      )

      result = TranSound::Service::ViewShow.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end

    it 'SAD: should not give contributions for non-existent show' do
      # GIVEN: no show exists locally

      # WHEN: we request to view the show
      request = OpenStruct.new(
        type: SHOW_TYPE,
        origin_id: SHOW_ID,
        show_fullname: "#{SHOW_TYPE}/#{SHOW_ID}",
        folder_name: ''
      )

      result = TranSound::Service::ViewShow.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end
  end
end