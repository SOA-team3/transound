# frozen_string_literal: true

require 'net/http'

# 使用Open3庫來執行Python腳本
require 'open3'

def apple_web_scraping
  # 執行Python爬蟲script
  script_file = 'app/domain/audio_datas/lib/apple_web_scraper.py'
  urls,  = Open3.capture2("python3 #{script_file}")

  mp3_url = urls.split[0]
  episode_url = urls.split[1]
  # 輸出爬下來的mp3網址
  # puts "MP3_URL: #{mp3_url}"
  # puts "Episode_url: #{episode_url}"
  [mp3_url, episode_url]
end

def google_web_scraping
  # 執行Python爬蟲script
  script_file = 'app/domain/audio_datas/lib/google_pod_episode_scraper.py'
  urls,  = Open3.capture2("python3 #{script_file}")

  episode_name = urls.split("\n")[0]
  mp3_url = urls.split("\n")[1]
  # 輸出爬下來的mp3網址
  puts "MP3_URL: #{mp3_url}"
  puts "Episode_name: #{episode_name}"
  # puts [mp3_url, episode_name]
  [mp3_url, episode_name]
end

# Utiliy of handle Audio data
module AudioDataUtils
  # Download Audio Data
  class AudioDownloader
    def download_audio(mp3_url, episode_name)

      # detect whether it is itunes API
      if episode_name.include?('podcasts.apple.com')
        episode_name = episode_name.split("/")[-2]
      # puts episode_name
      end

      local_file_path = "podcast_mp3_store/#{episode_name}.mp3"

      if File.exist?(local_file_path)
        puts 'This audio data has been downloaded!'
        return
      end

      mp3_url = 'https://audio.buzzsprout.com/jy79dri9up8p9tf3h6untzbdg04m?response-content-disposition=inline&'
      response = send_http_get_request(mp3_url)

      puts "302 response?: #{response}"
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
          puts new_uri
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

# mp3_url, episode_url = apple_web_scraping[0], apple_web_scraping[1]
# AudioDataUtils::AudioDownloader.new.download_audio(mp3_url, episode_url)

google_web_scrape_outcome = google_web_scraping
mp3_url, episode_name = google_web_scrape_outcome[0], google_web_scrape_outcome[1]
AudioDataUtils::AudioDownloader.new.download_audio(mp3_url, episode_name)

