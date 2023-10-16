# frozen_string_literal: true

module TranSound
  # provides data of a podcast episode
  class Episode
    def initialize(episode_data)
      @episode = episode_data
    end

    def description
      @episode['description']
    end

    def images
      @episode['images']
    end

    def language
      @episode['language']
    end

    def name
      @episode['name']
    end

    def release_date
      @episode['release_date']
    end

    def type
      @episode['type']
    end
  end
end
