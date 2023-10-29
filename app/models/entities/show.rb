# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TranSound
  module Entity
    # Domain entity for any podcast shows
    class Show < Dry::Struct
      include Dry.Types

      attribute :description, Strict::String
      attribute :images, Strict::Array
      attribute :name, Strict::String
      attribute :publisher, Strict::String
      attribute :type, Strict::String
      attribute :episodes, Strict::Hash
      def show_num?
        top > 10
      end
    end
  end
end
