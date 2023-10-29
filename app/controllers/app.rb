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

            # routing.redirect "episode/#{type}/#{id}"
            if %w[episode show].include?(type)
              routing.redirect "podcast_info/#{type}/#{id}"
            else
              # 處理未知網址
              routing.redirect '/'
            end
          end
        end

        routing.on String, String do |type, id|
          # GET /episode/id
          if type == 'episode'
            spotify_episode = TranSound::Podcast::EpisodeMapper
              .new(TEMP_TOKEN)
              .find("#{type}s", id, 'TW')
            view 'episode', locals: { episode: spotify_episode }
          elsif type == 'show'
            spotify_show = TranSound::Podcast::ShowMapper
              .new(TEMP_TOKEN)
              .find("#{type}s", id, 'TW')
            view 'show', locals: { show: spotify_show }
          else
            # 处理未知的type
            routing.redirect '/unknown'
          end
        end
      end
    end
  end
end
