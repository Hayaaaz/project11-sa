-- Insert fake documents
INSERT INTO documents (title, body)
VALUES
('Sermon 1', 'Grace and forgiveness.'),
('Sermon 2', 'Hope in difficult times.'),
('Announcement', 'Community dinner on Friday.');

-- Insert fake embeddings (10 dimensions)
INSERT INTO embeddings (document_id, embedding)
VALUES
(1, '[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]'::vector),
(2, '[0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0]'::vector),
(3, '[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]'::vector);

