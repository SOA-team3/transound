# frozen_string_literal: true

module TranSound
  module Podcast
    # Data Mapper: Podcast episode -> Episode
    class EpisodeMapper
      def initialize(token, gateway_class = Podcast::Api)
        @spot_token = token
        @gateway_class = gateway_class
        @gateway = gateway_class.new(@spot_token)
      end

      def find(type, id, market)
        data = @gateway.episode_data(type, id, market)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @spot_token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class)
          @episode = data
          @spot_token = token
          @gateway_class = gateway_class
        end

        def build_entity
          TranSound::Entity::Episode.new(
            description:,
            images:,
            language:,
            name:,
            release_date:,
            type:
          )
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
  end
end
