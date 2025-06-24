-- C. Επιστροφή πλάνου εκτέλεσης για το ερώτημα

-- Ερώτημα
EXPLAIN
SELECT name, character
FROM "Movie"
JOIN "Movie_Cast" ON "Movie_Cast".movie_id = "Movie".id
WHERE "Movie".title = 'Armageddon';

-- Δημιουργία δύο ευρετηρίων για επιτάχυνση του ερωτήματος

-- Ευρετήριο για τη στήλη title του πίνακα Movie
CREATE INDEX idx_movie_title ON "Movie"(title);

-- Ευρετήριο για τη στήλη movie_id του πίνακα Movie_Cast
CREATE INDEX idx_movie_cast_movie_id ON "Movie_Cast"(movie_id);

-- Επιστροφή πλάνου εκτέλεσης μετά τη δημιουργία των ευρετηρίων
EXPLAIN
SELECT name, character
FROM "Movie"
JOIN "Movie_Cast" ON "Movie_Cast".movie_id = "Movie".id
WHERE "Movie".title = 'Armageddon';

-- Αλλαγές στο Πλάνο Εκτέλεσης μετά τη δημιουργία των ευρετηρίων:

-- 1. Το Seq Scan στον πίνακα "Movie" αντικαθίσταται από Index Scan.
--    - Χρησιμοποιείται το ευρετήριο idx_movie_title για τη στήλη title, μειώνοντας τον αριθμό των εγγραφών που εξετάζονται.
-- 2. Το Seq Scan στον πίνακα "Movie_Cast" αντικαθίσταται από Index Scan.
--    - Χρησιμοποιείται το ευρετήριο idx_movie_cast_movie_id για τη στήλη movie_id, επιταχύνοντας τη διαδικασία αναζήτησης.
-- 3. Το κόστος του Hash Join μειώνεται, επειδή οι πίνακες που ενώνονται έχουν ήδη φιλτραριστεί μέσω των ευρετηρίων.
-- 4. Η συνολική απόδοση του ερωτήματος βελτιώνεται σημαντικά λόγω της μείωσης του κόστους και του αριθμού των εξεταζόμενων εγγραφών.

