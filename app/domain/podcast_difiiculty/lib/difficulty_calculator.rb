# frozen_string_literal: true
require 'yaml'
require_relative '../../../infrastructure/gateways/word_difficulty'

module TranSound
  module Mixins
    # line credit calculation methods
    module DifficultyCalculator
      TEST_TRANSCRIPT = YAML.safe_load_file('app/domain/podcast_difiiculty/lib/test_transcript.yml')

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
        TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficultyDict.new(transcript).create_word_difficulty_dict
        words_difficulty_dict = YAML.safe_load_file('app/domain/podcast_difiiculty/lib/temp_word_difficulty_dict.yml')
        words_difficulty_dict.to_h
      end
    end
  end
end
