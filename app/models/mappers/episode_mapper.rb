# frozen_string_literal: true

module TranSound
  module Podcast
    # Data Mapper: Podcast episode -> Episode entity
    class EpisodeMapper
      def initialize(token, gateway_class = Podcast::Api)
        @spot_token = token
        @gateway_class = gateway_class
        @gateway = gateway_class.new(@spot_token)
      end

      def find(type, id, market)
        data = @gateway.episode_data(type, id, market)
        save_audio_data(data)
        build_entity(data)
      end

      def save_audio_data(data)
        require 'net/http'

        # MP3 文件的 URL
        mp3_url = data['audio_preview_url']
        puts "mp3_url: #{mp3_url}"

        local_file_path = "app/models/mappers/audio_data_download/#{data['name']}.mp3"

        # 發送 HTTP GET 請求
        uri = URI(mp3_url)
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
          # 寫入檔案
          File.binwrite(local_file_path, response.body)

          puts "下載完成：#{local_file_path}"
        else
          puts "下載失败：#{response.code} - #{response.message}"
        end
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
