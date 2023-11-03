# frozen_string_literal: true

require 'roda'
require 'slim'

module TranSound
  # Application inherits from Roda
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing|
      routing.assets # load custom CSS

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

            # if %w[episode show].include?(type)
            #   routing.redirect "podcast_info/#{type}/#{id}"
            if type == 'episode'
              # Get podcast_info from Spotify
              podcast_info = TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')
            elsif type == 'show'
              podcast_info = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')
            else
              # handle unknown spotify_url
              routing.redirect '/'
            end

            # Add project to database
            Repository::For.entity(podcast_info).create(podcast_info)

            routing.redirect "podcast_info/#{type}/#{id}"
          end
        end

        routing.on String, String do |type, id|
          # GET /episode/id
          route_based_on_type(routing, type, id)
        end
      end
    end

    def route_based_on_type(routing, type, id)
      if type == 'episode'
        spotify_episode = TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')
        view 'episode', locals: { episode: spotify_episode }

        # Get project from database
        # episode = Repository::For.klass(Entity::Episode)
        #   .find_podcast_info(origin_id)
        # view 'episode', locals: { episode: }

      elsif type == 'show'
        spotify_show = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')
        view 'show', locals: { show: spotify_show }
      else
        # Handle unknown URLs (unknown type)
        routing.redirect '/'
      end
    end
  end
end
