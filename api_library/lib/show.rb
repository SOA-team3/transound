# frozen_string_literal: true

module TranSound
  # provides data of a podcast show
  class Show
    def initialize(show_data)
      @show = show_data
    end

    def description
      @show['description']
    end

    def images
      @show['images']
    end

    def name
      @show['name']
    end

    def publisher
      @show['publisher']
    end
  end
end
