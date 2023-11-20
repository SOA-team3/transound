# frozen_string_literal: true

require 'dry/monads'

module TranSound
  module Service
    # Retrieves array of all listed project entities
    class ListEpisodes
      include Dry::Monads::Result::Mixin

      def call(episodes_list)
        episodes = Repository::For.klass(Entity::Episode)
          .find_full_names(episodes_list)

        Success(episodes)
      rescue StandardError
        Failure('Could not access database')
      end
    end
  end
end