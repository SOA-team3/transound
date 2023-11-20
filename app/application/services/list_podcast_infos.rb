# frozen_string_literal: true

require 'dry/monads'

module TranSound
  module Service
    # Retrieves array of all listed episode entities
    class ListEpisodes
      include Dry::Monads::Result::Mixin

      def call(_episodes_list)
        # Load previously viewed episodes
        episodes = Repository::For.klass(Entity::Episode)
          .find_podcast_infos(session[:watching])

        Success(episodes)
      rescue StandardError
        Failure('Could not access database')
      end
    end

    # Retrieves array of all listed show entities
    # class ListShows
    #   def call(_shows_list)
    #     shows = Repository::For.klass(Entity::Show)
    #       .find_podcast_infos(session[:watching])

    #     Success(shows)
    #   rescue StandardError
    #     Failure('Could not access database')
    #   end
    # end
  end
end
