# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require './app/vector_embedding_endpoint'
require 'json'

RSpec.describe VectorEmbeddingEndpoint do
  include Rack::Test::Methods

  def app
    VectorEmbeddingEndpoint
  end

  let(:model_name) { 'model-name' }
  let(:sample_text) { 'This is a sample text for embedding' }
  let(:sample_embedding) { [0.1, 0.2, 0.3, 0.4, 0.5] }
  let(:mock_embedder) { instance_double('Services::TextEmbedder') }

  before do
    allow(Services::TextEmbedder).to receive(:new).and_return(mock_embedder)
    allow(mock_embedder).to receive(:embed).and_return(sample_embedding)
  end

  describe 'GET /vectorize' do
    it 'returns the app welcome message' do
      get '/vectorize'
      expect(last_response).to be_ok
    end
  end

  describe 'POST /vectorize' do
    context 'when model parameter is missing' do
      it 'returns an error message' do
        post '/vectorize', { text: 'some text' }
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('error')  
        expect(response_data[:message]).to eq('A model name is required.')  
      end
    end

    context 'when model parameter is present' do
      it 'embedder uses specified model' do
        specified_model = 'custom-model'

        post "/vectorize/#{specified_model}", { text: sample_text }

        expect(last_response).to be_ok
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('success')
        expect(Services::TextEmbedder).to have_received(:new).with(
          hash_including(model: specified_model)
        )
      end

      it 'embedder uses specified model when name has forward slashes' do
        specified_model = 'BAAI/bge-small-en-v1.5'

        post "/vectorize/#{specified_model}", { text: sample_text }

        expect(last_response).to be_ok
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('success')
        expect(Services::TextEmbedder).to have_received(:new).with(
          hash_including(model: specified_model)
        )
      end
    end

    context 'when text parameter is incorrect' do
      it 'returns 400 when text is missing' do
        post "/vectorize/#{model_name}"

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('error')
        expect(response_data[:message]).to include('Missing or empty text parameter')
      end

      it 'returns 400 when text is empty' do
        post "/vectorize/#{model_name}", { text: '' }

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('error')
        expect(response_data[:message]).to include('Missing or empty text parameter')
      end
    end

    context 'when text embedder raises errors' do
      it 'returns 500 for model initialization errors' do
        allow(Services::TextEmbedder).to receive(:new).and_raise(
          Services::TextEmbedder::ModelInitializationError.new('Failed to load model')
        )

        post "/vectorize/#{model_name}", { text: sample_text }

        expect(last_response.status).to eq(500)
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('error')
        expect(response_data[:message]).to include('Model initialization error')
      end

      it 'returns 500 for embedding errors' do
        allow(mock_embedder).to receive(:embed).and_raise(
          Services::TextEmbedder::EmbeddingError.new('Computation failed')
        )

        post "/vectorize/#{model_name}", { text: sample_text }

        expect(last_response.status).to eq(500)
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:status]).to eq('error')
        expect(response_data[:message]).to include('Embedding error')
      end
    end
  end
end
