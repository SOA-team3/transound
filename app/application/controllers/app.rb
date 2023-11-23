# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

# TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')

module TranSound
  # Application inherits from Roda
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: ['table_row.js', 'scripts.js']
    plugin :common_logger, $stderr

    use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    route do |routing|
      routing.assets # load custom CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      # TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
      #                                    App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get

      # GET /
      routing.root do
        # Get cookie viewer's previously seen projects
        session[:watching] ||= []

        episode_result = Service::ListEpisodes.new.call(session[:watching])
        # show_result = Service::ListShows.new.call(session[:watching])

        if episode_result.failure?
          flash[:error] = episode_result.failure
          viewable_episodes = []
        else
          episodes = episode_result.value!
          puts "episodes: #{episodes}"
          flash.now[:notice] = 'Add a Spotify Podcast Episode to get started' if episodes.none?
          session[:watching] = episodes.map(&:origin_id)
          puts "session[:watching]: #{session[:watching]}"
          viewable_episodes = Views::EpisodesList.new(episodes)
        end

        # if show_result.failure?
        #   flash[:error] = show_result.failure
        #   viewable_shows = []
        # else
        #   shows = result.value!
        #   flash.now[:notice] = 'Add a Spotify Podcast Show to get started' if shows.none?
        #   session[:watching] = shows.map(&:origin_id)
        #   viewable_shows = Views::ShowsList.new(shows)
        # end

        # puts "Session: #{session[:watching]}"
        # puts "Episodes: #{episodes}"
        # puts "Session: #{session[:watching]}"
        # puts "Shows: #{shows}"

        # if episodes.none?
        #   flash.now[:notice] = 'Add a Spotify Podcast Episode to get started'
        #   puts 'episodes = none'
        # end
        # if shows.none?
        #   flash.now[:notice] = 'Add a Spotify Podcast Show to get started'
        #   puts 'shows = none'
        # end

        # viewable_episodes = Views::EpisodesList.new(episodes)
        # viewable_shows = Views::ShowsList.new(shows)

        view 'home', locals: { episodes: viewable_episodes } # , shows: viewable_shows }
        # view 'home'
      end

      # podcast_info
      # routing.on 'podcast_info' do
      routing.on 'podcast_info' do
        puts TEMP_TOKEN_CONFIG

        routing.is do
          # POST /episode/
          routing.post do
            url_requests = Forms::NewPodcastInfo.new.call(routing.params)
<<<<<<< HEAD
            # puts "1 #{url_requests}"
            # puts "2 #{routing.params['spotify_url']}"

            # spot_url = routing.params['spotify_url']
=======
            puts "1 #{url_requests.inspect}"
            puts "2 #{routing.params['spotify_url']}"

            # url_requests = routing.params['spotify_url']
>>>>>>> d7572652020c53a4ca2940648a5b720fe9678fa4
            # unless (url_requests.include? 'open.spotify.com') &&
            #        (url_requests.split('/').count >= 3)
            #   flash[:error] = 'Invalid URL for a Spotify page (Require for a Spotify Episode or a Spotify Show)'
            #   response.status = 400
            #   routing.redirect '/'
            # end

            # puts "app1 #{url_requests}"

            podcast_info_made = Service::AddPodcastInfo.new.call(url_requests)

            if podcast_info_made.failure?
              flash[:error] = podcast_info_made.failure
              routing.redirect '/'
            end

            podcast_info = podcast_info_made.value!
            type = podcast_info.type
            id = podcast_info.origin_id

            # Add new project to watched set in cookies
            session[:watching].insert(0, podcast_info.origin_id).uniq!
            flash[:notice] = 'Podcast info added to your list'

            # Redirect viewer to episode page or show page
            routing.redirect "podcast_info/#{type}/#{id}"
          end
        end

        routing.on String, String do |type, id|
          # puts "Redirect_podcast_info: #{podcast_info}"
          puts "Redirect_type: #{type}"
          puts "Redirect_id: #{id}"
          # puts "Redirect_Podcast_info: #{podcast_info}"
          # puts "Redirect_Podcast_info.name: #{podcast_info.name}"

          # DELETE /podcast_info/{type}/{id}
          routing.delete do
            fullname = id.to_s
            session[:watching].delete(fullname)

            routing.redirect '/'
          end
<<<<<<< HEAD
=======

          languages_dict = Views::LanguagesList.new.lang_dict
          # GET /episode/id or /show/id
          if type == 'episode'
            view 'episode', locals: { episode: podcast_info, lang_dict: languages_dict }
          elsif type == 'show'
            view 'show', locals: { show: podcast_info, lang_dict: languages_dict }
          else
            # Handle unknown URLs (unknown type)
            routing.redirect '/'
          end
>>>>>>> d7572652020c53a4ca2940648a5b720fe9678fa4
        end
      end
    end
  end
end
