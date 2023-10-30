# frozen_string_literal: true

require 'sequel'

module TranSound
  module Database
    # Object Relational Mapper for Episode Entities
    class EpisodeOrm < Sequel::Model(:episodes)
      many_to_one :show,
                  class: :'TranSound::Database::EpisodeOrm'

      plugin :timestamps, update_on_create: true

      def self.find_or_create(episode_info)
        first(name: episode_info[:name]) || create(episode_info)
      end
    end
  end
end
