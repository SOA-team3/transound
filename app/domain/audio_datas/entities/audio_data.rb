# frozen_string_literal: true

require 'net/http'

# 使用Open3庫來執行Python腳本
require 'open3'

# 執行Python爬蟲script
script_file = 'app/domain/audio_datas/lib/apple_web_scraping.py'
urls,  = Open3.capture2("python3 #{script_file}")

mp3_url = urls.split[0]
episode_url = urls.split[1]

# 輸出爬下來的mp3網址
# puts "MP3_URL: #{mp3_url}"
# puts "episode_url: #{episode_url}"

# Utiliy of handle Audio data
module AudioDataUtils
  # Download Audio Data
  class AudioDownloader
    def download_audio(mp3_url, episode_url)
      episode_name = episode_url.split("/")[-2]
      puts episode_name
      local_file_path = "podcast_mp3_store/#{episode_name}.mp3"

      if File.exist?(local_file_path)
        puts 'This audio data has been downloaded!'
        return
      end

      response = send_http_get_request(mp3_url)
      puts response.code

      uri = URI(mp3_url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)

        # handle 302 redirect_issue
        if response.is_a?(Net::HTTPRedirection)
          # Follow the redirect and get the final location
          new_location = response['location']
          new_uri = URI(new_location)
          response = http.get(new_uri)
        end
      end

      if response.is_a?(Net::HTTPSuccess)
        write_to_file(local_file_path, response.body)
      else
        DownloadFailureHandler.new(response).handle
      end
    end

    private

    def send_http_get_request(url)
      #   puts url
      uri = URI(url)
      Net::HTTP.get_response(uri)
    end

    def write_to_file(file_path, content)
      File.binwrite(file_path, content)
      puts "下載完成：#{file_path}"
    end
  end

  # Handle downloading failure
  class DownloadFailureHandler
    def initialize(response)
      @response = response
    end

    def handle
      puts "下載失敗：#{@response.code} - #{@response.message}"
    end
  end
end

AudioDataUtils::AudioDownloader.new.download_audio(mp3_url, episode_url)
