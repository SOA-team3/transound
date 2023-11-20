# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'

module TranSound
  module Podcast
    module TranscribingUtils
      # Object for transcription by Whisper model and FFMPEG package
      class Transcription
        def initialize(audio_file_path)
          @audio_file_path = audio_file_path
          # Execute Python Scraping script
          @script_file = 'app/domain/audio_datas/lib/transcribe_whisper.py'
        end

        def transcribe
          # Open Python Script and write in "audio_file_path" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@audio_file_path)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return transcrption as String from Python script
            # output = stdout.read
            # output
          end
          # Must return again for the value of transcribe method
        end
      end
    end
  end
end
