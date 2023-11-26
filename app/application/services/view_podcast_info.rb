# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # Analyzes contributions to a project
    class AppraiseProject
      include Dry::Transaction

      step :ensure_watched_podcast_info
      step :retrieve_remote_podcast_info

      private

      # Steps

      def ensure_watched_podcast(input)
        if input[:watched_list].include? input[:requested].podcast_fullname
          Success(input)
        else
          Failure('Please first request this project to be added to your list')
        end
      end

      def retrieve_remote_podcast(input)
        if @type == 'episode'
          input[:podcast] = Repository::For.klass(Entity::Episode).find_full_name(
            input[:requested].id, input[:requested].type
          )

          input[:podcast] ? Success(input) : Failure('Project not found')
        elsif @type == 'show'
          input[:podcast] = Repository::For.klass(Entity::Show.find_full_name(
            input[:requested].id, input[:requested].type
          )

          input[:podcast] ? Success(input) : Failure('Project not found')
        rescue StandardError
          Failure('Having trouble accessing the database')
        end

      