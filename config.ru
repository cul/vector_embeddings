# frozen_string_literal: true

# config.ru

require 'bundler/setup'
require 'sinatra'
require './app/vector_embedding_endpoint'
run VectorEmbeddingEndpoint
