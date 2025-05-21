# frozen_string_literal: true

require 'transformers-rb'
require 'logger'

module Services
  class TextEmbedder
    class EmbeddingError < StandardError; end
    class ModelInitializationError < StandardError; end
    class InvalidInputError < ArgumentError; end

    def initialize(model:)
      raise InvalidInputError, 'A model name is required.' unless model

      @model_name = model

      initialize_pipeline
    end

    def embed(text)
      validate_text(text)

      begin
        result = @embedding_pipeline.call(text)
      rescue StandardError => e
        raise EmbeddingError, "Failed to generate embeddings: #{e.message}"
      end

      validate_result(result)

      result
    end

    private

    def initialize_pipeline
      @embedding_pipeline = Transformers.pipeline('embedding', @model_name)
    rescue StandardError => e
      raise ModelInitializationError, "Failed to create embedding pipeline: #{e.message}"
    end

    def validate_text(text)
      return if text.is_a?(String) && !text.strip.empty?

      raise InvalidInputError, 'Text must be a non-empty string'
    end

    def validate_result(result)
      return if result.is_a?(Array) && !result.empty?

      raise EmbeddingError, 'Embedding pipeline output is malformed or incomplete'
    end
  end
end
