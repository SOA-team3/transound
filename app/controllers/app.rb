# frozen_string_literal: true

require 'roda'
require 'slim'

module TranSound
  # Application inherits from Roda
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :public, root: 'app/views/public'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing|
      routing.assets # load custom CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public

      # GET /
      routing.root do
        view 'home'
      end

      # podcast_info
      routing.on 'podcast_info' do
        routing.is do
          # POST /episode/
          routing.post do
            spot_url = routing.params['spotify_url']
            routing.halt 400 unless (spot_url.include? 'open.spotify.com') &&
                                    (spot_url.split('/').count >= 3)
            type, id = spot_url.split('/')[-2..]

            if type == 'episode'
              # Get podcast_info from Spotify
              podcast_info = TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')
            elsif type == 'show'
              podcast_info = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')
            else
              # handle unknown spotify_url
              routing.redirect '/'
            end

            # Add data to database
            Repository::For.entity(podcast_info).create(podcast_info)

            routing.redirect "podcast_info/#{type}/#{id}"
          end
        end

        routing.on String, String do |type, id|
          # GET /episode/id or /show/id
          if type == 'episode'
            # Get project from database
            spotify_episode = Repository::For.klass(Entity::Episode).find_podcast_info(id)
            view 'episode', locals: { episode: spotify_episode }

          elsif type == 'show'
            # Get data from API
            # spotify_show = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')

            # Get data from database
            spotify_show = Repository::For.klass(Entity::Show).find_podcast_info(id)
            view 'show', locals: { show: spotify_show }
          else
            # Handle unknown URLs (unknown type)
            routing.redirect '/'
          end
        end
      end
    end
  end
end
