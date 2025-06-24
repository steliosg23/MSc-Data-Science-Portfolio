-- Α. Δημιουργία όψεων

-- Δημιουργία όψης Actor από τα γνωρίσματα distinct person_id, gender, name του πίνακα Movie_Cast
CREATE VIEW "Actor" AS
SELECT DISTINCT 
    person_id, 
    gender, 
    name
FROM 
    "Movie_Cast";

-- Δημιουργία όψης CrewMember από τα γνωρίσματα distinct person_id, gender, name του πίνακα Movie_Crew
CREATE VIEW "CrewMember" AS
SELECT DISTINCT 
    person_id, 
    gender, 
    name
FROM 
    "Movie_Crew";

-- Δημιουργία όψης Person χρησιμοποιώντας την ένωση των πινάκων Actor και CrewMember
CREATE VIEW "Person" AS
SELECT 
    person_id, 
    gender, 
    name
FROM 
    "Actor"
UNION
SELECT 
    person_id, 
    gender, 
    name
FROM 
    "CrewMember";
