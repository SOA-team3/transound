# frozen_string_literal: true

require 'dry-validation'

module TranSound
  module Forms
    # Form validation for Spotify episode/show URL
    class NewPodcastInfo < Dry::Validation::Contract
      URL_REGEX = %r{https:\/\/open\.spotify\.com\/(show|episode)\/[a-zA-Z0-9]+}.freeze

      params do
        required(:remote_url).filled(:string)
      end

      rule(:remote_url) do
        unless URL_REGEX.match?(value)
          key.failure('is an invalid address for a Spotify podcast episode or show')
        end
      end
    end
  end
end