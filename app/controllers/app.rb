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

      routing.on 'episode' do
        routing.is do
          # POST /episode/
          routing.post do
            spot_url = routing.params['spotify_url']
            routing.halt 400 unless (spot_url.include? 'open.spotify.com') &&
                                    (spot_url.split('/').count >= 3)
            type, id = spot_url.split('/')[-2..]

            routing.redirect "episode/#{type}/#{id}"
          end
        end

        routing.on String, String do |type, id|
          # GET /episode/type/id
          routing.get do
            puts "app.rb: #{TEMP_TOKEN}"
            spotify_episode = TranSound::Podcast::EpisodeMapper
              .new(TEMP_TOKEN)
              .find(type, id, 'TW')

            view 'episode', locals: { episode: spotify_episode }
          end
        end
      end
    end
  end
end
