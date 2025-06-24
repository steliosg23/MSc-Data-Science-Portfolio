-- Β. Εντοπισμός Λανθασμένων Εγγραφών στον Πίνακα Person

-- Βρείτε τα person_ids τα οποία εμφανίζονται πάνω από 1 φορά με διαφορετικό name ή gender
SELECT 
    person_id
FROM 
    "Person"
GROUP BY 
    person_id
HAVING 
    COUNT(DISTINCT name) > 1 OR COUNT(DISTINCT gender) > 1;

-- Κάντε τις απαιτούμενες ενημερώσεις στους αρχικούς πίνακες Movie_Cast και Movie_Crew

-- Για τον πίνακα Movie_Cast: Ενημέρωση εγγραφών για διπλότυπα person_id με βάση το name και το gender
UPDATE "Movie_Cast" 
SET name = subquery.name, 
    gender = subquery.gender
FROM (
    SELECT 
        person_id, 
        MAX(name) AS name, 
        MAX(gender) AS gender
    FROM 
        "Movie_Cast"
    GROUP BY 
        person_id
) AS subquery
WHERE "Movie_Cast".person_id = subquery.person_id;

-- Για τον πίνακα Movie_Crew: Ενημέρωση εγγραφών για διπλότυπα person_id με βάση το name και το gender
UPDATE "Movie_Crew" 
SET name = subquery.name, 
    gender = subquery.gender
FROM (
    SELECT 
        person_id, 
        MAX(name) AS name, 
        MAX(gender) AS gender
    FROM 
        "Movie_Crew"
    GROUP BY 
        person_id
) AS subquery
WHERE "Movie_Crew".person_id = subquery.person_id;

-- Βεβαιωθείτε ότι το κάθε person_id αντιστοιχεί σε μία μοναδική εγγραφή στον πίνακα Person
-- Ανακατασκευή της όψης Person για να αντικατοπτρίζει τις αλλαγές στους αρχικούς πίνακες
DROP VIEW IF EXISTS "Person";

CREATE VIEW "Person" AS
SELECT 
    person_id, 
    gender, 
    name
FROM 
    "Movie_Cast"
UNION
SELECT 
    person_id, 
    gender, 
    name
FROM 
    "Movie_Crew";
