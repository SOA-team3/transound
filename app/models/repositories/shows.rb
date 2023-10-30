# frozen_string_literal: true

module TranSound
  module Repository
    # Repository for Shows
    class Shows
      def self.find_id(id)
        rebuild_entity Database::ShowOrm.first(id:)
      end

      def self.find_origin_id(origin_id)
        rebuild_entity Database::ShowOrm.first(origin_id:)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Show.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          name: db_record.name,
          images: db_record.images,
          publisher: db_record.publisher,
          type: db_record.type
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_show|
          Shows.rebuild_entity(db_show)
        end
      end

      def self.db_find_or_create(entity)
        Database::ShowOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
