# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'
require 'yaml'

module TranSound
  module Podcast
    module WordDifficultyUtils
      # Object for calculating Word Difficulty by nltk Library
      class NLTKWordDifficulty
        def initialize(word)
          @word = word
          puts "initialize word: #{word}"
          # Execute Python translating script
          @script_file = 'python_utils/word_difficulty_calulator/nltk_word_difficulty.py'
        end

        def calculate_word_difficulty
          # Open Python Script and write in "word" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@word)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return word-difficulty as String from Python script
          end
          # Must return again for the value of translate method
        end
      end

      # Object for calculating Word-Difficulty by nltk Library and write in Word-Difficulty-Dict in Yaml file
      class NLTKWordDifficultyDict
        def initialize(transcript)
          @transcript = transcript
          puts "initialize transcript: #{transcript}"
          # Execute Python translating script
          @script_file = 'python_utils/word_difficulty_calulator/nltk_word_difficulty_dict.py'
        end

        def create_word_difficulty_dict
          # Open Python Script and write in "word" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@transcript)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return ?? as ?? from Python script
          end
        end
      end

    end
  end
end

# nltk version(free) - calculate the difficulty of one single word
# word = 'free'
# word_difficulty = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficulty.new(word).calculate_word_difficulty
# puts "Word_difficulty:\n#{word_difficulty}"

# nltk version(free) - calculate the difficulty of one single word
# TEST_TRANSCRIPT = YAML.safe_load_file('app/domain/podcast_difiiculty/lib/test_transcript.yml')
# word_difficulty_dict = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficultyDict.new(TEST_TRANSCRIPT).create_word_difficulty_dict
# puts "Word_difficulty:\n#{word_difficulty_dict}"