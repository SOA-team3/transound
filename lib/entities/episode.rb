# frozen_string_literal: true

<<<<<<< HEAD
=======
require 'dry-types'
require 'dry-struct'

>>>>>>> 6980dbc1078283c122bbe1dbcf6ed0b8a93d8467
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
