# frozen_string_literal: true

require 'sequel'

module TranSound
  module Database
    # Object-Relational Mapper for Show Entities
    class ShowOrm < Sequel::Model(:shows)
      one_to_many :episode,
                  class: :'TranSound::Database::ShowOrm',
                  key: :show_id

      plugin :timestamps, update_on_create: true
    end
  end
end
