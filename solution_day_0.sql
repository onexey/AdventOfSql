/* 
 * Find the top cities in each country (max top 3 cities for each country)
 * with the highest average naughty_nice_score for children who received gifts, 
 * but only include cities with at least 5 children. Write them in any order below.
*/

;WITH
    FilteredCities AS
    (
        -- cities with at least 5 children
        SELECT city
        FROM Children
        GROUP BY city
        HAVING COUNT(city) >= 5
    ),
    AverageScoresPerCity AS
    (
        -- average naughty_nice_score per city
        SELECT  chld.country,
                chld.city, 
                AVG(chld.naughty_nice_score) AS avg_nns, 
                DENSE_RANK() OVER (PARTITION BY chld.country ORDER BY AVG(chld.naughty_nice_score) DESC) AS rank
        FROM Children chld
            INNER JOIN ChristmasList
                ON chld.child_id = ChristmasList.child_id
                AND was_delivered = 1
            INNER JOIN FilteredCities
                ON chld.city = FilteredCities.city
        GROUP BY chld.country, chld.city
    )
SELECT *
FROM AverageScoresPerCity
WHERE rank <= 3
ORDER BY country, avg_nns DESC, city


-- This is the expected result, but I believe the question is worded incorrectly.
;WITH
    FilteredCities AS
    (
        -- cities with at least 5 children
        SELECT city
        FROM Children
            INNER JOIN ChristmasList
                ON Children.child_id = ChristmasList.child_id
        GROUP BY city
        HAVING COUNT(city) >= 5
    ),
    AverageScoresPerCity AS
    (
        -- average naughty_nice_score per city
        SELECT  chld.country,
                chld.city, 
                AVG(chld.naughty_nice_score) AS avg_nns, 
                DENSE_RANK() OVER (PARTITION BY chld.country ORDER BY AVG(chld.naughty_nice_score) DESC) AS rank
        FROM Children chld
            INNER JOIN ChristmasList
                ON chld.child_id = ChristmasList.child_id
                AND was_delivered = 1
            INNER JOIN FilteredCities
                ON chld.city = FilteredCities.city
        GROUP BY chld.country, chld.city
    )
SELECT *
FROM AverageScoresPerCity
WHERE rank <= 3
ORDER BY country, avg_nns DESC, city
