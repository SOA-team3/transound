# frozen_string_literal: true

require_relative '../../helpers/acceptance_helper'
require_relative 'pages/episode_page'
require_relative 'pages/home_page'

describe 'Episode Page Acceptance Tests' do
  include PageObject::PageFactory

  before do
    DatabaseHelper.wipe_database
    # Headless error? https://github.com/leonid-shevtsov/headless/issues/80
    # @headless = Headless.new
    @browser = Watir::Browser.new
  end

  after do
    @browser.close
    # @headless.destroy
  end

  it '(HAPPY) should see episode content if episode exists' do
    # GIVEN: user has requested and created a episode
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{EPISODE_NAME}"
      page.add_new_episode(good_url)
    end

    # WHEN: user goes to the episode page
    visit(EpisodePage, using_params: { owner_name: USERNAME,
                                       episode_name: EPISODE_NAME }) do |page|
      # THEN: they should see the episode details
      _(page.episode_title).must_include USERNAME
      _(page.episode_title).must_include EPISODE_NAME
      _(page.contribution_table_element.present?).must_equal true

      usernames = ['SOA-KunLin', 'Yuan-Yu', 'luyimin']
      _(usernames.include?(page.contributors[0].username)).must_equal true
      _(usernames.include?(page.contributors[1].username)).must_equal true
      _(usernames.include?(page.contributors[3].username)).must_equal true

      _(page.folders.count).must_equal 10
      _(page.files.count).must_equal 2
    end
  end

  it '(HAPPY) should be able to traverse to subfolders' do
    # GIVEN: user has created a episode
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{EPISODE_NAME}"
      page.add_new_episode(good_url)
    end

    # WHEN: they go to the episode's page
    visit(EpisodePage, using_params: { owner_name: USERNAME,
                                       episode_name: EPISODE_NAME }) do |page|
      # WHEN: and click a link to a folder
      page.folder_called('views_objects/').link.click

      # THEN: they should see the episode and contribution details
      _(page.folders.count).must_equal 0
      _(page.files.count).must_equal 5
    end
  end

  it '(BAD) should report error if subfolder does not exist' do
    # GIVEN: user has created a episode
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{EPISODE_NAME}"
      page.add_new_episode(good_url)
    end

    # WHEN user goes to a non-existent folder of the episode
    visit(EpisodePage,
          using_params: { owner_name: USERNAME,
                          episode_name: EPISODE_NAME,
                          folder: 'foobar' })

    # THEN: user should see a warning message
    on_page HomePage do |page|
      _(page.warning_message.downcase).must_include 'could not find'
    end
  end

  it '(HAPPY) should report an error if episode not requested' do
    # GIVEN: user has not requested a episode yet, even though it exists
    episode = CodePraise::Github::EpisodeMapper
      .new(GITHUB_TOKEN)
      .find(USERNAME, EPISODE_NAME)
    CodePraise::Repository::For.entity(episode).create(episode)

    # WHEN: they go directly to the episode's page
    visit(EpisodePage, using_params: { owner_name: USERNAME,
                                       episode_name: EPISODE_NAME })

    # THEN: they should should be returned to the homepage with a warning
    on_page HomePage do |page|
      _(page.warning_message.downcase).must_include 'request'
    end
  end
end