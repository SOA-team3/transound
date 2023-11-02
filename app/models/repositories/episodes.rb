# frozen_string_literal: true

module TranSound
  module Repository
    # Repository for Episode Entities
    class Episodes
      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::EpisodeOrm.first(id:)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::EpisodeOrm.first(origin_id:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Episode already exists' if find(entity)

        db_record = Database::EpisodeOrm.create(entity.to_attr_hash)
        rebuild_entity(db_record)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Episode.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          name: db_record.name,
          description: db_record.description,
          images: db_record.images,
          language: db_record.language,
          release_date: db_record.release_date,
          type: db_record.type
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_episode|
          Episodes.rebuild_entity(db_episode)
        end
      end

      def self.db_find_or_create(entity)
        Database::EpisodeOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
