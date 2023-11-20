# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # Transaction to store episode from Github API to database
    class AddEpisode
      include Dry::Transaction

      step :parse_url
      step :find_episode
      step :store_episode

      private

      def parse_url(input)
        if input.success?
          owner_name, episode_name = input[:remote_url].split('/')[-2..-1]
          Success(owner_name: owner_name, episode_name: episode_name)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def find_episode(input)
        if (episode = episode_in_database(input))
          input[:local_episode] = episode
        else
          input[:remote_episode] = episode_from_github(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_episode(input)
        episode =
          if (new_episode = input[:remote_episode])
            Repository::For.entity(new_episode).create(new_episode)
          else
            input[:local_episode]
          end
        Success(episode)
      rescue StandardError => error
        App.logger.error error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def episode_from_github(input)
        Github::episodeMapper
          .new(App.config.GITHUB_TOKEN)
          .find(input[:owner_name], input[:episode_name])
      rescue StandardError
        raise 'Could not find that episode on Github'
      end

      def episode_in_database(input)
        Repository::For.klass(Entity::episode)
          .find_full_name(input[:owner_name], input[:episode_name])
      end
    end
  end
end