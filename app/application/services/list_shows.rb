# frozen_string_literal: true

require 'dry/monads'

module TranSound
  module Service
    # Retrieves array of all listed project entities
    class ListShows
      include Dry::Monads::Result::Mixin

      def call(shows_list)
        shows = Repository::For.klass(Entity::Show)
          .find_full_names(shows_list)

        Success(shows)
      rescue StandardError
        Failure('Could not access database')
      end
    end
  end
end