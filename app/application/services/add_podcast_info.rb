# frozen_string_literal: true

require 'dry/transaction'

TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')

module TranSound
  module Service
    # Transaction to store episode from Spotify API to database
    class AddPodcastInfo
      include Dry::Transaction

      # @temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
      #                                             App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
      step :parse_url
      step :find_podcast_info
      step :store_podcast_info

      private

      def parse_url(input)
        puts "add p info: #{input.inspect}"
        if input.success?
          @type, id = input.values[:spotify_url].split('/')[-2..]
          Success(type: @type, id:)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def find_podcast_info(input)
        if @type == 'episode'
          if (episode = episode_in_database(input))
            input[:local_episode] = episode
          else
            input[:remote_episode] = episode_from_spotify(input)
          end
          Success(input)
        elsif @type == 'show'
          if (show = show_in_database(input))
            input[:local_show] = show
          else
            input[:remote_show] = show_from_spotify(input)
          end
          Success(input)
        end
      rescue StandardError => e
        Failure(e.to_s)
      end

      def store_podcast_info(input)
        if @type == 'episode'
          episode =
            if (podcast_info = input[:remote_episode])
              Repository::For.entity(podcast_info).create(podcast_info)
            else
              input[:local_episode]
              flash[:error] = "Podcast #{@type} information already exists"
              routing.redirect '/'
            end
          Success(episode)
        elsif @type == 'show'
          show =
            if (podcast_info = input[:remote_show])
              Repository::For.entity(podcast_info).create(podcast_info)
            else
              input[:local_show]
              flash[:error] = "Podcast #{@type} information already exists"
              routing.redirect '/'
            end
          Success(show)
        end
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def episode_from_spotify(input)
        @temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                         App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
        # puts "#{@type} #{input[:id]}"
        TranSound::Podcast::EpisodeMapper
          .new(@temp_token)
          .find("#{@type}s", input[:id], 'TW')
      rescue StandardError
        raise 'Could not find that episode on Spotify'
      end

      def show_from_spotify(input)
        @temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                         App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
        TranSound::Podcast::ShowMapper
          .new(@temp_token)
          .find("#{@type}s", input[:id], 'TW')
      rescue StandardError
        raise 'Could not find that show on Spotify'
      end

      def episode_in_database(input)
        Repository::For.klass(Entity::Episode)
          .find_podcast_info(input[:id])
        # view 'episode', locals: { episode: spotify_episode, lang_dict: languages_dict }
      end

      def show_in_database(input)
        Repository::For.klass(Entity::Show)
          .find_podcast_info(input[:id])
        # view 'show', locals: { show: spotify_show }
      end
    end
  end
end
