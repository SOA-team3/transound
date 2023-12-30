# frozen_string_literal: true

require 'json'
require 'yaml'
require_relative '../../../infrastructure/gateways/word_difficulty'

module TranSound
  module Mixins
    # line credit calculation methods
    module DifficultyCalculator
      def word_split(sentence)
        sentence.downcase.gsub(/[^a-z\s]/, '').split
      end

      # Difficulty-level calculated per word and return a word-difficulty-dict
      # Note: 2 min podcast take 45 min to analyse
      def words_difficulty_calculate(word_array)
        words_difficulty_dict = {}
        word_array.each do |word|
          word_difficulty = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficulty.new(word).calculate_word_difficulty
          words_difficulty_dict[word] = word_difficulty
        end
        words_difficulty_dict
      end

      # Return a word-difficulty-dict by input transcript
      def words_difficulty_dict_create(transcript)
        words_difficulty_dict = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficultyDict.new(transcript).create_word_difficulty_dict
        # 上面的 gsub 用於處理類似 "i'm" 的情況，將其轉換為 "i"m"
        json_string = words_difficulty_dict.to_s.gsub("'", '"').gsub('": "', '": "').gsub('": "', '": "')
        JSON.parse(json_string)
      rescue JSON::ParserError => e
        puts "JSON parsing error: #{e.message}"
        nil
      end

      def dict_filter(dict, level)
        if %w[easy moderate difficult unclassified].include?(level)
          dict.select { |_key, value| value == level }
        else
          {}
        end
      end

    end
  end
end

