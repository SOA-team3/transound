# frozen_string_literal: true

require 'dry/transaction'

module TranSound
    module Service
        class ViewPodcastInfo
            include Dry::Transaction

            step :ensure_watched_podcast_info
            step :retrieve_remote_podcast_info

            private

            def ensure_watched_podcast_info(input)
                if input[:watched_list].include? input[:requested]
                    Success(input)
                else
                    Failure('Please first request this podcast to be added to your list')
                end
            end

            def retrieve_remote_podcast_info(input)
                input[:episode] = 