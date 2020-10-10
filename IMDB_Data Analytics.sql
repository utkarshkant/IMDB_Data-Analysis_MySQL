# create a new database
CREATE DATABASE imdb;

# instantiate the imdb database
USE imdb;

# preview all tables in the schema
SHOW TABLES;

#####################################################################################
-- DESCRIBE

# metadata on actors table
DESCRIBE actors;

# get info on movies_directors
DESCRIBE movies_directors;

# get info on movies_genres
DESCRIBE movies_genres;

# get info on directors_genres
DESCRIBE directors_genres;

# get info on roles
DESCRIBE roles;

#####################################################################################
-- SELECT

# get info on movies
DESCRIBE movies;

# list all movies
SELECT * FROM movies;

SELECT name, year FROM movies;

SELECT rankscore, name FROM movies;  # rows order is in same order as that of the table

#####################################################################################
-- LIMIT & OFFSET

# get first 20 entries in the table
SELECT rankscore, name
FROM movies
LIMIT 20;

# get second 20 entries in the table
SELECT name, rankscore 
FROM movies 
LIMIT 20 
OFFSET 20;	# ignore the first 20 entries in the table

# get third 20 entries in the table
SELECT name, rankscore
FROM movies
LIMIT 20
OFFSET 40;	# ignore first 40 entries in the table

#####################################################################################
-- ORDER BY

# get 10 most recent movies
SELECT name, rankscore, year
FROM movies
ORDER BY year DESC	# default order is ascending
LIMIT 10;

# get 10 oldest movies
SELECT name, rankscore, year
FROM movies
ORDER BY year
LIMIT 10;

#####################################################################################
-- DISTINCT

# get unique movie genres
SELECT DISTINCT(genre)
FROM movies_genres;

# calculate total different genres
SELECT COUNT(genre), COUNT(DISTINCT(genre))
FROM movies_genres;

# get entries for unique full names
SELECT DISTINCT first_name, last_name	# DISTINCT is applied on both features
FROM actors;

# get entries for unique full names
SELECT DISTINCT first_name, last_name
FROM directors;

#####################################################################################
-- WHERE

# list all movies with rankscore > 9
SELECT name, year, rankscore
FROM movies
WHERE rankscore >= 9;

# 20 top rated movies from best to last
SELECT name, year, rankscore
FROM movies
WHERE rankscore >= 9
ORDER BY rankscore DESC
LIMIT 20;

# CONDITION's outputs: TRUE, FALSE, NULL
# Comparison operators: =, <> or !=, <, >, <=, >=

# get all comedy movies
SELECT * 
FROM movies_genres
WHERE genre = 'Comedy';

# get all movies that are not horror
SELECT *
FROM movies_genres
WHERE genre != 'Horror';

/**
NULL is a special keyword in SQL
NULL => does not exist / unknown / missing

The `=` operator does not work with NULL and it will give you an empty result set
**/
SELECT name, year, rankscore
FROM movies
WHERE rankscore = NULL;		# `=` operator does not work with NULL

# IS NULL
SELECT name, year, rankscore
FROM movies
WHERE rankscore IS NULL
LIMIT 20;

# IS NOT NULL
SELECT name, year, rankscore
FROM movies
WHERE rankscore IS NOT NULL
LIMIT 20;

#####################################################################################
-- LOGICAL OPERATORS
-- AND, OR, NOT, ALL, ANY, BETWEEN, EXISTS, IN, LIKE, SOME

# multiple search filters
SELECT name, year, rankscore
FROM movies
WHERE rankscore > 9
AND year > 2000
ORDER BY rankscore DESC;

# filter for after year 2000
SELECT name, year, rankscore
FROM movies
WHERE rankscore > 9
AND NOT year <= 2000
ORDER BY rankscore DESC
LIMIT 20;

# BETWEEN > inclusive range
SELECT name, year, rankscore
FROM movies
WHERE year BETWEEN 1990 AND 2000	# year >= 1990 AND year <= 2000
	AND rankscore IS NOT NULL
ORDER BY year DESC;

SELECT name, year, rankscore
FROM movies
WHERE year BETWEEN 2000 AND 1990;	# empty set since 2000 !< 1990

# IN => OR conditional
SELECT director_id, genre
FROM directors_genres
WHERE genre IN ('Comedy','Horror');	# movies where genre='Comedy' OR genre='Horror'

# LIKE => text matching
SELECT name, year, rankscore
FROM movies
WHERE name LIKE 'Tis%';		# name starting with 'Tis'

-- `%` is a wildcard character

# first_name ends with 'es'
SELECT first_name, last_name
FROM actors
WHERE first_name LIKE '%es';

# `_` for exactly 1 character
SELECT first_name, last_name
FROM actors
WHERE first_name LIKE 'Agn_s';

/**
Since `%` is a wildcard in SQL, therefore, to use `%` as a character in string, we must use the escape character `\` before `%` character
For example: 
	SELECT student_name, score FROM student_scores WHERE score = '96\%';
Similarly, for `_` character. Use the escape character for string matching '\_'
**/

#####################################################################################
-- Aggregate Functions - COUNT, MIN, MAX, SUM, AVG

# first year in the db
SELECT MIN(year) FROM movies;

# last year in the db
SELECT MAX(year) FROM movies;

# how many records in the table movies
SELECT COUNT(*) FROM movies;		-- '388269'
SELECT COUNT(year) FROM movies;		-- '388269'

# how many movies in the db were released in and after 2000
SELECT COUNT(*)
FROM movies
WHERE year>=2000;	-- '57649'

#####################################################################################
-- GROUP BY

# number of movies released per year
SELECT year, COUNT(year) as total_movies
FROM movies
GROUP BY year
ORDER BY year;

SELECT year, COUNT(year) as total_movies
FROM movies
GROUP BY year
ORDER BY total_movies DESC;

/**
GROUP BY is often used with COUNT, MIN, MAX and SUM
If the column being grouped upon contains NULL values, then all such records will be grouped together
**/

#####################################################################################
-- HAVING

# years which have >1000 movies in the DB
SELECT year, COUNT(year) as total_movies
FROM movies
GROUP BY year
HAVING total_movies>1000
ORDER BY total_movies DESC;

/*
Order of execution:
1. GROUP BY to create groups
2. apply the AGGREGATE FUNCTION
3. apply HAVING condition
*/

/*
- HAVING is often used with GROUP BY but it is not mandatory
- without GROUP BY, HAVING is used as WHERE clause
SELECT name, year FROM movies HAVING year>2000

Differences between HAVING and WHERE?
- WHERE is applied on individual rows while HAVING is applied on groups
- WHERE is applied before grouping while HAVING is applied after grouping
*/

SELECT year, COUNT(year) total_movies
FROM movies
WHERE rankscore>9
GROUP BY year
HAVING total_movies>20;

#####################################################################################
-- JOIN
-- combines data from multiple tables

# for each movie, get name and genre
SELECT m.name, g.genre
FROM movies m
JOIN movies_genres g 
ON m.id=g.movie_id
LIMIT 20;

# default JOIN is Inner Join

/*
Natural Join
- When both tables have the same column name for their matching IDs, then you do not need to specify the column on which they have to join
- t1: c1, c2
- t2: c1, c3, c4
SELECT * FROM t1 JOIN t2;
SELECT * FROM t1 JOIN t2 USING(c1)
- Above queries will return c1,c2,c3,c4
*/

/*
Types of JOIN
1. INNER JOIN or JOIN
2. OUTER JOIN
	- LEFT OUTER JOIN or LEFT JOIN
    - RIGHT OUTER JOIN or RIGHT JOIN
    - FULL OUTER JOIN or FULL JOIN
*/

# LEFT JOIN
SELECT m.name, g.genre
FROM movies m
LEFT JOIN movies_genres g
ON m.id=g.movie_id;

# 3-way JOIN and k-way JOIN
SELECT a.first_name, a.last_name 
FROM actors a
JOIN roles r ON a.id=r.actor_id
JOIN movies m ON m.id = r.movie_id AND m.name='Officer 444';

/*
NOTE: Joins are computationally expensive when we have large tables
*/

#####################################################################################
-- Sub Queries, Nested Queries or Inner Queries

# List all the actors in the movie Schindler's list
DESCRIBE actors;
DESCRIBE roles;
DESCRIBE movies;

SELECT first_name, last_name
FROM actors
WHERE id IN (
	SELECT actor_id FROM roles WHERE movie_id IN (
		SELECT id FROM movies WHERE name="Schindler's List"
        )
	);

/**
Syntax

SELECT col_name, [, col_name]
FROM table1 [, table2]
WHERE col_name OPERATOR(
	SELECT col_name [, col_name]
    FROM table1 [, table2]
    [WHERE])
    
-> First the inner query is executed and then the outer query is executed using the output values in the inner query
-> IN, NOT IN, EXISTS, NOT EXISTS, ANY, ALL, Comparison Operators
-> EXISTS returns true if the subquery returns one or more records or NULL
-> ANY operator returns TRUE if any of the subquery values meet the condition
-> ALL operator returns TRUE if all of the subquery values meet the condition
**/

# get all movies with highest rankscore
SELECT * FROM movies where rankscore >= ALL (SELECT MAX(rankscore) from movies);

#####################################################################################
-- Data Manipulation
-- SELECT, INSERT, UPDATE, DELETE

# INSERT
INSERT INTO movies(id, name, year, rankscore)
VALUES 
	(412321, 'Thor', 2011, 7), 
    (412322, 'Iron Man', 2008, 7.9),
    (412323, 'Iron Man 2', 2010, 7);

SELECT * FROM movies WHERE id=412321;
-- 412321	Thor	2011	7 

# UPDATE
UPDATE movies SET rankscore=9 WHERE id=412321;
/**
Syntax
UPDATE table_name SET col1=val1, col2=val2 WHERE condition
**/

SELECT * FROM movies WHERE id=412321;
-- 412321	Thor	2011	9 

# DELETE
DELETE FROM movies WHERE id=412321;  # deletes the row


#####################################################################################
-- Data Definition Manipulation
-- CREATE, TRUNCATE, ALTER, ADD, MODIFY, DROP

# CREATE
CREATE TABLE language(
	id INT PRIMARY KEY, 
    lang VARCHAR(50) NOT NULL
    );

/** 
# SQL Data Types

NUMERIC
- BIG
- TINYINT
- SMALLINT
- INT
- BIGINT
- DECIMAL
- NUMERIC
- FLOAT
- REAL

DATE/TIME
- DATE
- TIME
- DATETIME
- TIMESTAMP
- YEAR

CHARACTER/STRING
- CHAR
- VARCHAR
- VARCHAR (MAX)
- TEXT

UNICODE CHARACTER/STRING
- NCHAR
- NVARCHAR
- NVARCHAR(MAX)
- TEXT

BINARY
- BINARY
- VARBINARY
- VARBINARY(MAX)
- NTEXT

MISCELLANEOUS
- CLOG
- BLOB
- XML
- JSON

**/

/**
# CONSTRAINTS

NOT NULL - Ensures that a column cannot have a NULL value
UNIQUE - Ensures that all values in a column are different
PRIMARY KEY - A combination of a NOT NULL and UNIQUE. Uniquely identifies each row in a table
FOREIGN KEY - Uniquely identifies a row/record in another table
CHECK - Ensures that all values in a column satisfies in a specific column
DEFAULT - Sets a default value for a column when no value is specified
INDEX - Used to create and retrieve data from the database very quickly

**/

# ALTER
ALTER TABLE language ADD country VARCHAR(50);
ALTER TABLE language MODIFY country VARCHAR(60);
ALTER TABLE language DROP country;

# DROP
DROP TABLE table_name;
DROP TABLE IF EXISTS table_name;  # deletes the whole table from the schema

# TRUNCATE
TRUNCATE TABLE table_name;  # removes the contents of the table / cleans the table

#####################################################################################
-- Data Control Language - for DB Admins

# controls who has what kind of access to what data in the database
# GRANT, REVOKE