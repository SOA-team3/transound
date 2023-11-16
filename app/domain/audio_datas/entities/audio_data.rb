# frozen_string_literal: true

require 'net/http'

# Open3 library to execute Python script
require 'open3'

module TranSound
  module Podcast
    module WebScrapingUtils
      # Handle for different web scrapping pattern

      # Object for web scraping on Apple Podcast
      class AppleWebScraping
        # Execute Python scraping script
        def initialize
          @script_file = 'app/domain/audio_datas/lib/apple_web_scraper.py'
          @urls = Open3.capture2("python3 #{@script_file} ").split
        end

        def scrap
          mp3_url = @urls[0]
          episode_url = @urls[1]
          # Return scraped mp3_url of Python script
          # puts "MP3_URL: #{mp3_url}"
          # puts "Episode_url: #{episode_url}"
          [mp3_url, episode_url]
        end
      end

      # Object for web scraping on Google Podcast
      class GoogleWebScraping
        def initialize(episode_name)
          @google_pod_url = "https://podcasts.google.com/search/#{episode_name}"
          # Execute Python Scraping script
          @script_file = 'app/domain/audio_datas/lib/google_pod_episode_scraper.py'
        end

        def scrap
          # Open Python Script and write in "google_pod_url" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@google_pod_url)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return scraped mp3_url of Python script
            # output = stdout.read
            # output
          end
          # Must return again for the value of google_web_scraping method
        end
      end
    end
  end
end

# Google podcast version
# episode_name = 'YUYUの日本語Podcast Vol.233 【仕事のこと】それは仕事？仕事ごっこ？(YUYU Japanese Podcast)'
# mp3_url = TranSound::Podcast::WebScrapingUtils::WebScraper.new.google_web_scraping(episode_name)
# puts "mp3_url: #{mp3_url}"

# Utiliy of handle Downloading audio data
# module AudioDataUtils
#   # Download Audio Data
#   class AudioDownloader
#     def download_audio(mp3_url, episode_name)

#       # detect whether it is itunes API
#       if episode_name.include?('podcasts.apple.com')
#         episode_name = episode_name.split("/")[-2]
#       # puts episode_name
#       end

#       local_file_path = "podcast_mp3_store/#{episode_name}.mp3"

#       if File.exist?(local_file_path)
#         puts 'This audio data has been downloaded!'
#         return
#       end

#       response = send_http_get_request(mp3_url)

#       puts "302 response?: #{response}"
#       uri = URI(mp3_url)
#       Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
#         request = Net::HTTP::Get.new(uri)
#         response = http.request(request)

#         # handle 302 redirect_issue
#         if response.is_a?(Net::HTTPRedirection)
#           # Follow the redirect and get the final location
#           new_location = response['location']
#           new_uri = URI(new_location)
#           response = http.get(new_uri)
#           puts new_uri
#         end
#       end

#       if response.is_a?(Net::HTTPSuccess)
#         write_to_file(local_file_path, response.body)
#       else
#         DownloadFailureHandler.new(response).handle
#       end
#     end

#     private

#     def send_http_get_request(url)
#       #   puts url
#       uri = URI(url)
#       Net::HTTP.get_response(uri)
#     end

#     def write_to_file(file_path, content)
#       File.binwrite(file_path, content)
#       puts "下載完成：#{file_path}"
#     end
#   end

#   # Handle downloading failure
#   class DownloadFailureHandler
#     def initialize(response)
#       @response = response
#     end

#     def handle
#       puts "下載失敗：#{@response.code} - #{@response.message}"
#     end
#   end
# end

# Apple itune API version
# mp3_url, episode_url = apple_web_scraping[0], apple_web_scraping[1]
# AudioDataUtils::AudioDownloader.new.download_audio(mp3_url, episode_url)
