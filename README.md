Sinatra app for converting text to vector embeddings by providing a name for the embedding model in the path.

For example: 

curl -X POST http://vector-embeddings.library.columbia.edu/vectorize/BAAI/bge-small-en-v1.5 \
  -d "text=hello world"

  This will return a json response of the form:

{"status":"success","embeddings": [0.1, 0.2, 0.3, 0.4, 0.5] }

  with the length of the returned embeddings array equal to the dimension of the provided model.
