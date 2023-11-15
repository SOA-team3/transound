# frozen_string_literal: true

require_relative 'show'

module Views
  # View for a a list of show entities
  class ShowsList
    def initialize(shows)
      @shows = shows.map.with_index { |show, i| Show.new(show, i) }
    end

    def each(&episode)
      @shows.each do |episode|
        episode.call show
      end
    end

    def any?
      @shows.any?
    end
  end
end


