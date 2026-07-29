-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Documents table
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL
);

-- Embeddings table
CREATE TABLE embeddings (
    id SERIAL PRIMARY KEY,
    document_id INT REFERENCES documents(id),
    embedding vector(10)  -- using 10 dimensions for simplicity
);

-- HNSW index (derived state)
CREATE INDEX embeddings_hnsw_idx ON embeddings USING hnsw (embedding vector_l2_ops);

