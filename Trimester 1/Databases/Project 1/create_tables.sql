-- File: create_tables.sql
CREATE TABLE "Movie" (
    id INT PRIMARY KEY,
    adult BOOLEAN NOT NULL,
    budget DECIMAL(15, 2) NOT NULL,
    homepage VARCHAR(255),
    original_language VARCHAR(10),
    original_title VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    tagline TEXT,  
    overview TEXT,
    popularity DECIMAL(10, 2),
    release_date DATE,
    revenue DECIMAL(15, 2),
    runtime FLOAT
);

CREATE TABLE "Genre" (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE "Collection" (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE "ProductionCompany" (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE "Keyword" (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE "Movie_Cast" (
    cid INT PRIMARY KEY,
    movie_id INT NOT NULL,
    character TEXT,  
    gender CHAR(1),
    person_id INT,
    name VARCHAR(255)
);

CREATE TABLE "Movie_Crew" (
    cid INT PRIMARY KEY,
    movie_id INT NOT NULL,
    department VARCHAR(255),
    gender CHAR(1),
    person_id INT,
    job VARCHAR(255),
    name VARCHAR(255)
);

CREATE TABLE "Ratings" (
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating DECIMAL(3, 1),
    PRIMARY KEY (user_id, movie_id)
);

-- Relationship tables without PRIMARY KEY or UNIQUE constraints
CREATE TABLE "HasKeyword" (
    movie_id INT NOT NULL,
    keyword_id INT NOT NULL
);

CREATE TABLE "BelongsToCollection" (
    movie_id INT NOT NULL,
    collection_id INT NOT NULL
);

CREATE TABLE "HasGenre" (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL
);

CREATE TABLE "HasProductionCompany" (
    movie_id INT NOT NULL,
    pc_id INT NOT NULL
);
