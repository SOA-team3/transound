# frozen_string_literal: true

module Views
  # View for a single episode entity
  class Episode
    def initialize(episode, index = nil)
      @episode = episode
      @index = index
    end

    def entity
      @episode
    end

    def link
      "/podcast_info/episode/#{origin_id}"
    end

    def index_str
      "project[#{@index}]"
    end

    def name
      @episode.name
    end

    def episode_url
      @episode.episode_url
    end

    def release_date
      @episode.release_date
    end
  end
end
