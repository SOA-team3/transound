# frozen_string_literal: true

require_relative '../../helpers/acceptance_helper'
require_relative 'pages/show_page'
require_relative 'pages/home_page'

describe 'Show Page Acceptance Tests' do
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

  it '(HAPPY) should see show content if show exists' do
    # GIVEN: user has requested and created a show
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{SHOW_NAME}"
      page.add_new_show(good_url)
    end

    # WHEN: user goes to the show page
    visit(ShowPage, using_params: { owner_name: USERNAME,
                                       show_name: SHOW_NAME }) do |page|
      # THEN: they should see the show details
      _(page.show_title).must_include USERNAME
      _(page.show_title).must_include SHOW_NAME
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
    # GIVEN: user has created a show
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{SHOW_NAME}"
      page.add_new_show(good_url)
    end

    # WHEN: they go to the show's page
    visit(ShowPage, using_params: { owner_name: USERNAME,
                                       show_name: SHOW_NAME }) do |page|
      # WHEN: and click a link to a folder
      page.folder_called('views_objects/').link.click

      # THEN: they should see the show and contribution details
      _(page.folders.count).must_equal 0
      _(page.files.count).must_equal 5
    end
  end

  it '(BAD) should report error if subfolder does not exist' do
    # GIVEN: user has created a show
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{SHOW_NAME}"
      page.add_new_show(good_url)
    end

    # WHEN user goes to a non-existent folder of the show
    visit(ShowPage,
          using_params: { owner_name: USERNAME,
                          show_name: SHOW_NAME,
                          folder: 'foobar' })

    # THEN: user should see a warning message
    on_page HomePage do |page|
      _(page.warning_message.downcase).must_include 'could not find'
    end
  end

  it '(HAPPY) should report an error if show not requested' do
    # GIVEN: user has not requested a show yet, even though it exists
    show = CodePraise::Github::ShowMapper
      .new(GITHUB_TOKEN)
      .find(USERNAME, SHOW_NAME)
    CodePraise::Repository::For.entity(show).create(show)

    # WHEN: they go directly to the show's page
    visit(ShowPage, using_params: { owner_name: USERNAME,
                                       show_name: SHOW_NAME })

    # THEN: they should should be returned to the homepage with a warning
    on_page HomePage do |page|
      _(page.warning_message.downcase).must_include 'request'
    end
  end
end