# frozen_string_literal: true

require 'spec_helper'
require 'services/text_embedder'

RSpec.describe Services::TextEmbedder do
  let(:embedding_pipeline) { double('embedding_pipeline') }
  let(:fake_embedding) { [0.1, 0.2, 0.3] }
  let(:embedder) { Services::TextEmbedder.new(model: 'model_name') }

  before do
    allow(Transformers).to receive(:pipeline)
      .with('embedding', 'model_name')
      .and_return(embedding_pipeline)
  end

  describe '#initialize' do
    it 'initializes the model pipeline' do
      expect(embedder.instance_variable_get(:@embedding_pipeline)).to eq(embedding_pipeline)
    end

    it 'assigns the model name correctly' do
      allow(Transformers).to receive(:pipeline).with('embedding', 'custom-model').and_return(embedding_pipeline)
      embedder = Services::TextEmbedder.new(model: 'custom-model')
      expect(embedder.instance_variable_get(:@model_name)).to eq('custom-model')
    end
  end

  describe '#embed' do
    it 'returns the embedding vector for a given text' do
      allow(embedding_pipeline).to receive(:call).with('hello world').and_return(fake_embedding)
      embedder = Services::TextEmbedder.new(model: 'model_name')
      result = embedder.embed('hello world')
      expect(result).to eq(fake_embedding)
    end
    it 'raises an error if text is empty' do
      expect { embedder.embed('  ') }.to raise_error(ArgumentError, /non-empty string/)
    end

    it 'raises an error if text is not a string' do
      expect { embedder.embed(nil) }.to raise_error(ArgumentError)
      expect { embedder.embed(123) }.to raise_error(ArgumentError)
    end

    it 'raises an error if embedding_pipeline returns nil' do
      allow(embedding_pipeline).to receive(:call).and_return(nil)
      expect { embedder.embed('text') }.to raise_error(Services::TextEmbedder::EmbeddingError)
    end

    it 'raises an error if embedding_pipeline returns malformed data (not an array)' do
      allow(embedding_pipeline).to receive(:call).and_return({})
      expect { embedder.embed('text') }.to raise_error(Services::TextEmbedder::EmbeddingError)
    end
  end
end
