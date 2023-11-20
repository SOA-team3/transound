# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # Transaction to store show from Github API to database
    class AddShow
      include Dry::Transaction

      step :parse_url
      step :find_show
      step :store_show

      private

      def parse_url(input)
        if input.success?
          owner_name, show_name = input[:remote_url].split('/')[-2..-1]
          Success(owner_name: owner_name, show_name: show_name)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def find_show(input)
        if (show = show_in_database(input))
          input[:local_show] = show
        else
          input[:remote_show] = show_from_github(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_show(input)
        show =
          if (new_show = input[:remote_show])
            Repository::For.entity(new_show).create(new_show)
          else
            input[:local_show]
          end
        Success(show)
      rescue StandardError => error
        App.logger.error error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def show_from_github(input)
        Github::showMapper
          .new(App.config.GITHUB_TOKEN)
          .find(input[:owner_name], input[:show_name])
      rescue StandardError
        raise 'Could not find that show on Github'
      end

      def show_in_database(input)
        Repository::For.klass(Entity::show)
          .find_full_name(input[:owner_name], input[:show_name])
      end
    end
  end
end