-- Remove duplicates from HasGenre
DELETE FROM "HasGenre"
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM "HasGenre"
    GROUP BY movie_id, genre_id
);

-- Remove duplicates from HasKeyword
DELETE FROM "HasKeyword"
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM "HasKeyword"
    GROUP BY movie_id, keyword_id
);

-- Remove duplicates from BelongsToCollection
DELETE FROM "BelongsToCollection"
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM "BelongsToCollection"
    GROUP BY movie_id, collection_id
);

-- Remove duplicates from HasProductionCompany
DELETE FROM "HasProductionCompany"
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM "HasProductionCompany"
    GROUP BY movie_id, pc_id
);
