# frozen_string_literal: true

require 'sequel'

module TranSound
  module Database
    # Object-Relational Mapper for Shows
    class ShowOrm < Sequel::Model(:shows)
      one_to_many :episodes,
                  class: :'TranSound::Database::ShowOrm',
                  key: :show_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(show_info)
        first(name: show_info[:name]) || create(show_info)
      end
    end
  end
end
