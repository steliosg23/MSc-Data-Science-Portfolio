-- Δημιουργία πρωτεύοντος κλειδιού για τον πίνακα "HasGenre"
ALTER TABLE "HasGenre"
ADD CONSTRAINT pk_hasgenre PRIMARY KEY (movie_id, genre_id);

-- Δημιουργία πρωτεύοντος κλειδιού για τον πίνακα "HasKeyword"
ALTER TABLE "HasKeyword"
ADD CONSTRAINT pk_haskeyword PRIMARY KEY (movie_id, keyword_id);

-- Δημιουργία πρωτεύοντος κλειδιού για τον πίνακα "BelongsToCollection"
ALTER TABLE "BelongsToCollection"
ADD CONSTRAINT pk_belongstocollection PRIMARY KEY (movie_id, collection_id);

-- Δημιουργία πρωτεύοντος κλειδιού για τον πίνακα "HasProductionCompany"
ALTER TABLE "HasProductionCompany"
ADD CONSTRAINT pk_hasproductioncompany PRIMARY KEY (movie_id, pc_id);

-- Δημιουργία πρωτεύοντος κλειδιού για τον πίνακα "Ratings"
ALTER TABLE "Ratings"
ADD CONSTRAINT pk_ratings PRIMARY KEY (user_id, movie_id);

