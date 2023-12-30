# frozen_string_literal: true

require_relative '../lib/difficulty_calculator'

module TranSound
  module Entity
    # Entity for different scorings of a transcript
    class DifficultyScores
      include Mixins::DifficultyCalculator

      attr_reader :transcript

      def initialize(transcript:)
        @transcript = transcript
      end

      def words_array
        word_split(@transcript)
      end

      def words_difficulty_dict_by_words_array
        words_difficulty_calculate(words_array)
      end

      def words_difficulty_dict_by_transcript
        words_difficulty_dict_create(transcript)
      end
    end
  end
end

# test

# TEST_TRANSCRIPT = YAML.safe_load_file('app/domain/podcast_difficulty/lib/test_transcript.yml')
# difficulty_score = TranSound::Entity::DifficultyScores.new(transcript: TEST_TRANSCRIPT)
# puts difficulty_score.transcript
# words_difficulty_dict = difficulty_score.words_difficulty_dict_by_transcript
# puts "words_difficulty_dict: #{words_difficulty_dict}"
# puts difficulty_score.dict_filter(words_difficulty_dict, 'easy')
