# frozen_string_literal: true

require 'transformers-rb'
require 'logger'

module Services
  # Service for using sentence transformers to generate vector document embeddings
  class TextEmbedder
    IN_MEMORY_MODEL_CACHE ||= {} # rubocop:disable Style/MutableConstant

    class EmbeddingError < StandardError; end
    class ModelInitializationError < StandardError; end
    class InvalidInputError < ArgumentError; end

    # Returns a class-cached instance of the requested model
    def self.get(model:)
      IN_MEMORY_MODEL_CACHE[model] = new(model:) unless IN_MEMORY_MODEL_CACHE.key?(model)
      IN_MEMORY_MODEL_CACHE[model]
    end

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
      device = if Torch::Backends::MPS.available?
                 Torch.device('mps')
               else
                 Torch.device('cpu')
               end

      logger = Logger.new($stdout)
      logger.info("Initializing embedding pipeline with device: #{device.type}")

      @embedding_pipeline = Transformers.pipeline('embedding', @model_name, device:)
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
