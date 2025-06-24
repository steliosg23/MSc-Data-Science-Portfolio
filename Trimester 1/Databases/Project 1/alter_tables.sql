-- File: alter_tables.sql

ALTER TABLE "HasKeyword"
ADD CONSTRAINT fk_haskeyword_movie
FOREIGN KEY (movie_id) REFERENCES "Movie"(id),
ADD CONSTRAINT fk_haskeyword_keyword
FOREIGN KEY (keyword_id) REFERENCES "Keyword"(id);

ALTER TABLE "BelongsToCollection"
ADD CONSTRAINT fk_belongstocollection_movie
FOREIGN KEY (movie_id) REFERENCES "Movie"(id),
ADD CONSTRAINT fk_belongstocollection_collection
FOREIGN KEY (collection_id) REFERENCES "Collection"(id);

ALTER TABLE "HasGenre"
ADD CONSTRAINT fk_hasgenre_movie
FOREIGN KEY (movie_id) REFERENCES "Movie"(id),
ADD CONSTRAINT fk_hasgenre_genre
FOREIGN KEY (genre_id) REFERENCES "Genre"(id);

ALTER TABLE "HasProductionCompany"
ADD CONSTRAINT fk_hasproductioncompany_movie
FOREIGN KEY (movie_id) REFERENCES "Movie"(id),
ADD CONSTRAINT fk_hasproductioncompany_pc
FOREIGN KEY (pc_id) REFERENCES "ProductionCompany"(id);

ALTER TABLE "Movie_Cast"
ADD CONSTRAINT fk_movie_cast_movie
FOREIGN KEY (movie_id) REFERENCES "Movie"(id);

ALTER TABLE "Movie_Crew"
ADD CONSTRAINT fk_movie_crew_movie
FOREIGN KEY (movie_id) REFERENCES "Movie"(id);
