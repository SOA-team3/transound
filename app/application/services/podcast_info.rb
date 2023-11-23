# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # Analyzes contributions to a project
    class PodcastInfo
      include Dry::Transaction

      step :ensure_watched_project
      step :retrieve_remote_project

      private

      # Steps

      def ensure_watched_project(input)
        if input[:watched_list].include? input[:requested].id
          Success(input)
        else
          Failure('Please first request this project to be added to your list')
        end
      end

      def retrieve_remote_project(input)
        if input[:requested].type == 'episode'
          input[:episode] = Repository::For.klass(Entity::Episode).find_podcast_info(
            input[:requested].id
          )
          input[:episode] ? Success(input) : Failure('Episode not found')
        elsif input[:requested].type == 'show'
          input[:show] = Repository::For.klass(Entity::Show).find_podcast_info(
            input[:requested].id
          )
          input[:show] ? Success(input) : Failure('Show not found')
        end
      rescue StandardError
        Failure('Having trouble accessing the database')
      end
    end
  end
end
