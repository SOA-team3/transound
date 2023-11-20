# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

require_relative 'helpers'

module TranSound
  # Web App
  class App < Roda
    include RouteHelpers

    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'table_row.js'
    plugin :common_logger, $stderr

    route do |routing| # rubocop:disable Metrics/BlockLength
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public

      # GET /
      routing.root do
        # Get cookie viewer's previously seen episodes
        session[:watching] ||= []

        result = Service::ListEpisodes.new.call(session[:watching])

        if result.failure?
          flash[:error] = result.failure
          viewable_episodes = []
        else
          episodes = result.value!
          if episodes.none?
            flash.now[:notice] = 'Add a Github episode to get started'
          end

          session[:watching] = episodes.map(&:fullname)
          viewable_episodes = Views::EpisodesList.new(episodes)
        end

        view 'home', locals: { episodes: viewable_episodes }
      end

      routing.on 'episode' do # rubocop:disable Metrics/BlockLength
        routing.is do
          # POST /episode/
          routing.post do
            url_request = Forms::NewEpisode.new.call(routing.params)
            episode_made = Service::AddEpisode.new.call(url_request)

            if episode_made.failure?
              flash[:error] = episode_made.failure
              routing.redirect '/'
            end

            episode = episode_made.value!
            session[:watching].insert(0, episode.fullname).uniq!
            flash[:notice] = 'Episode added to your list'
            routing.redirect "episode/#{episode.owner.username}/#{episode.name}"
          end
        end

        routing.on String, String do |owner_name, episode_name|
          # DELETE /episode/{owner_name}/{episode_name}
          routing.delete do
            fullname = "#{owner_name}/#{episode_name}"
            session[:watching].delete(fullname)

            routing.redirect '/'
          end

          # GET /episode/{owner_name}/{episode_name}[/folder_namepath/]
          routing.get do
            path_request = EpisodeRequestPath.new(
              owner_name, episode_name, request
            )

            session[:watching] ||= []

            result = Service::AppraiseEpisode.new.call(
              watched_list: session[:watching],
              requested: path_request
            )

            if result.failure?
              flash[:error] = result.failure
              routing.redirect '/'
            end

            appraised = result.value!
            episode_folder = Views::EpisodeFolderContributions.new(
              appraised[:episode], appraised[:folder]
            )

            view 'episode', locals: { episode_folder: }
          end
        end
      end
    end
  end
end