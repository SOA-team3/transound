# frozen_string_literal: true

module TranSound
  module Entity
    # Domain entity for any podcast episode
    class Episode < Dry::Struct
      include Dry.Types

      attribute :description, Strict::String
      attribute :images, Strict::Array
      attribute :language, Strict::String
      attribute :name, Strict::String
      attribute :release_date, Strict::String
      attribute :type, Strict::String
    end
  end
end
