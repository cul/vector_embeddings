# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require './lib/services/text_embedder'

# a Sinatra API for generating vector document embeddings
class VectorEmbeddingEndpoint < Sinatra::Base
  configure do
    set :show_exceptions, false
    set :raise_errors, false
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    also_reload './**/*.rb'
    set :show_exceptions, true
    set :raise_errors, true
  end

  get '/vectorize' do
    'Vector Embeddings Web App'
  end

  post %r{/vectorize(?:/(.*))?} do
    content_type :json

    model_name = params[:captures]&.first
    text = params['text']

    return error_response('A model name is required.', 400) if model_name.nil? || model_name.empty?
    return error_response('Missing or empty text parameter', 400) if text.nil? || text.empty?

    begin
      embedder = Services::TextEmbedder.get(model: model_name)

      text_embeddings = embedder.embed(text)

      {
        status: 'success',
        embeddings: text_embeddings
      }.to_json
    rescue Services::TextEmbedder::InvalidInputError => e
      error_response("Invalid input: #{e.message}", 400)
    rescue Services::TextEmbedder::ModelInitializationError => e
      error_response("Model initialization error: #{e.message}", 500)
    rescue Services::TextEmbedder::EmbeddingError => e
      error_response("Embedding error: #{e.message}", 500)
    rescue StandardError
      error_response('Unexpected error occurred', 500)
    end
  end

  private

  def error_response(error_message, status_code = 400)
    status status_code
    {
      status: 'error',
      message: error_message
    }.to_json
  end
end
