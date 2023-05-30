USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT table_name,
       table_rows
FROM information_schema.tables
WHERE table_schema = 'imdb';

SELECT (SELECT COUNT(*) FROM director_mapping) AS row_count_director,
	   (SELECT COUNT(*) FROM genre) AS row_count_genre,
       (SELECT COUNT(*) FROM movie) AS row_count_movie,
       (SELECT COUNT(*) FROM names) AS row_count_names,
       (SELECT COUNT(*) FROM ratings) AS row_count_ratings,
       (SELECT COUNT(*) FROM role_mapping) AS row_count_role_mapping;
       
/* 
Conclusion:

director_mapping table contains 3867 number of rows
genre table contains 14662 number of rows
movie table contains 7997 number of rows
names table contains 25735 number of rows
ratings table contains 7997 number of rows
role_mapping table contains 15615 number of rows
*/
       
-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NullsInId,
  SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS NullsInTitle,
  SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS NullsInYear,
  SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS NullsInDatePublished,
  SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS NullsInDuration,
  SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS NullsInCountry,
  SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS NullsInWorldwideGrossIncome,
  SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS NullsInLanguages,
  SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS NullsInProductionCompany
FROM movie;


/*
Conclusion:
id column does not have any null values as expected as it is a primary key. 
worlwide_gross_income has the highest number of null values.
title, year, date and duration attributes are not having any null values.
*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+*/

SELECT year as 'Year', COUNT(id) as number_of_movies
FROM movie
GROUP BY year;

/*
Year wise movie count 
Year 2017 - 3052 number of movies released
Year 2018 - 2944 number of movies released
Year 2019 - 2001 number of movies released
*/

/*
Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT month(date_published) AS month_num, COUNT(id) AS number_of_movies FROM movie
GROUP BY month_num
ORDER BY month_num;
 
-- Highest number of movies were released in the month of Jan, Mar, Sept and Oct
-- Lowest number of movies were released in the month of July and December


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT country, count(id) AS Total_movies FROM movie
GROUP BY country
HAVING country LIKE 'USA' OR country LIKE 'INDIA'
ORDER BY count(id) DESC;

-- USA produced 2260 number of movies in the year 2019 whereas, India produced 1007 movies

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT genre FROM genre;

-- There are a total of 13 unique genres in RSVP movies which also includes 'Others'

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

WITH genre_rank AS (
SELECT genre, COUNT(movie_id) AS Movie_Count, DENSE_RANK() over (ORDER BY COUNT(movie_id) DESC) AS Rnk
FROM genre
GROUP BY genre
)
SELECT genre, Movie_Count
FROM genre_rank
WHERE Rnk = 1;

-- 4285 number of movies were produced in the genre category of Drama

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH one_genre_table AS (
SELECT movie_id, count(movie_id) FROM genre
GROUP BY movie_id
HAVING count(movie_id) =1
)
SELECT COUNT(*) AS Movies_with_one_genre FROM one_genre_table;

-- There are 3289 number of movies with only one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre,ROUND(AVG(duration),2) AS avg_duration
FROM movie m 
	INNER JOIN genre g
		ON m.id = g.movie_id
GROUP BY genre
ORDER BY ROUND(AVG(duration),2) DESC;

-- Average duration of Drama genre is about 107 min and the same for Fantasy is 106 min
-- Horror genre is having an average duration of 93 min
-- Movies in the action genre has a relatively longer duration than any other genres

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/
-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH rank_table AS (
SELECT genre, count(movie_id) AS movie_count, RANK() OVER (ORDER BY count(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre
)
SELECT * FROM rank_table
WHERE genre = 'Thriller';

-- The genre thriller ranks 3rd when it comes to number of movies produced

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT ROUND(min(avg_rating),2) AS min_avg_rating,
	   ROUND(max(avg_rating),2) AS max_avg_rating,
	   min(total_votes) AS min_total_votes,
	   max(total_votes) AS max_total_votes,
	   min(median_rating) AS min_median_rating,
	   max(median_rating) AS max_median_rating
FROM ratings;

-- There is movie with the total votes of 725138

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH Movies_ranked AS (
SELECT title, avg_rating, DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS Movie_rank
FROM movie m
	INNER JOIN ratings r
    ON m.id = r.movie_id
)
SELECT * FROM Movies_ranked
WHERE Movie_rank <=10;

-- Kirket and Love in Kilnerry have the highest average rating that is 10.0. 

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating,COUNT(movie_id) AS Movie_Count FROM ratings
GROUP BY median_rating
ORDER BY Movie_Count DESC;

-- median rating of 7 has the highest number of movie count that is 2257
-- median rating of 1 has the lowest number of movie count that is 94

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- It's ok if RANK() or DENSE_RANK() is used too
-- Type your code below:

SELECT * FROM (
	SELECT production_company, COUNT(movie_id) AS movie_count, DENSE_RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS prod_company_rank
	FROM movie m
		INNER JOIN ratings r
		ON m.id = r.movie_id
	WHERE avg_rating > 8
	GROUP BY production_company
	HAVING production_company IS NOT null) AS prod_rank_table
WHERE prod_company_rank = 1;

-- Both Dream warrior pictures and National Theatre have produced 3 super hit movies


-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre, COUNT(g.movie_id) AS movie_Count
FROM genre g
	INNER JOIN ratings r
    ON g.movie_id = r.movie_id
		INNER JOIN movie m
        ON g.movie_id = m.id
WHERE country = 'USA' AND year = 2017 AND MONTH(date_published) = 3 AND total_votes > 1000
GROUP BY genre
ORDER BY COUNT(movie_id) DESC;

-- 16 movies were produced with the Drama genre

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH the_movies AS (
SELECT title, avg_rating, genre, ROW_NUMBER() OVER (PARTITION BY title ORDER BY avg_rating DESC) as row_rank
FROM movie m
	INNER JOIN ratings r
    ON m.id = r.movie_id
		INNER JOIN genre g
		ON m.id = g.movie_id
WHERE title REGEXP '^The' AND avg_rating > 8
)
SELECT title,avg_rating,genre
FROM the_movies
WHERE row_rank = 1
ORDER BY avg_rating DESC;

-- The Brighton Miracle has the highest rating (9.5) that starts with 'The'

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(movie_id) AS movie_count
FROM ratings r
	INNER JOIN movie m
    ON r.movie_id = m.id
WHERE date_published BETWEEN '2018-04-01' AND '2019-04-01' AND median_rating =8;

-- 361 movies were given a median rating greater than 8 during 1st april 2018 to 1st april 2019
-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT country, SUM(total_votes) AS Total_votes
FROM movie m
	INNER JOIN ratings r
    ON m.id = r.movie_id
WHERE country IN ('Germany','Italy')
GROUP BY country;

-- German movies beat the Italian movies by 28745 votes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT (SELECT COUNT(id) 
	    FROM names
        WHERE name IS NULL) AS name_nulls,
			(SELECT COUNT(id)
             FROM names
             WHERE height IS NULL) AS height_nulls,
				(SELECT COUNT(id)
                 FROM names
                 WHERE date_of_birth IS NULL) AS date_of_birth_nulls,
					(SELECT COUNT(id)
                     FROM names
                     WHERE known_for_movies IS NULL) AS known_for_movies_nulls;

-- There are no Null value in the column 'name'.
-- The attribute height has the highest number of null values that is 17335

/* The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/
-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH genres_top_3 AS (
SELECT genre FROM (	
    SELECT genre,count(g.movie_id)AS movie_count,RANK() OVER (ORDER BY COUNT(g.movie_id) DESC) AS genre_rank 
	FROM genre g
		INNER JOIN ratings r
		ON r.movie_id = g.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
) AS top_genres		
WHERE genre_rank <=3
),
top_3_directors AS (
SELECT name AS director_name, COUNT(dm.movie_id) AS movie_count, RANK() OVER (ORDER BY COUNT(dm.movie_id) DESC) AS director_rank
FROM names n
	INNER JOIN director_mapping dm
	ON dm.name_id = n.id
		INNER JOIN genre g
        ON g.movie_id = dm.movie_id
			INNER JOIN ratings r
            ON dm.movie_id = r.movie_id
WHERE genre in (SELECT * FROM genres_top_3) AND avg_rating > 8
GROUP BY name
ORDER BY COUNT(movie_id) DESC
)
SELECT director_name, movie_count
FROM top_3_directors
WHERE director_rank <=3;

-- James Mangold has the highest number of movies (4) that has an avg rating of 8 in the top 3 genres

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH actor_rank AS (
SELECT name AS actor_name, count(rm.movie_id) AS movie_count, DENSE_RANK() OVER (ORDER BY COUNT(rm.movie_id) DESC) AS Rnk
FROM names n
	INNER JOIN role_mapping rm
    ON n.id = rm.name_id
		INNER JOIN ratings r
        ON rm.movie_id = r.movie_id
WHERE median_rating >= 8
GROUP BY name
ORDER BY movie_count DESC
)
SELECT actor_name,movie_count
FROM actor_rank
WHERE Rnk <=2;

-- Mammooty and Mohanlal are the top two actors whose movies have a median rating >= 8
-- Mammootty has the movie count of 8 and Mohanlal has the movie count of 5

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|    vote_count		|	prod_comp_rank    |
+------------------+--------------------+---------------------+
| The Archers	   |		830			|		    1	  	  |
|	.			   |		.			|			.		  |
|	.			   |		.			|			.		  |
+------------------+--------------------+---------------------+*/
-- Type your code below:

WITH top_3_company AS (
SELECT production_company, sum(total_votes) AS Vote_count, DENSE_RANK() OVER (ORDER BY sum(total_votes) DESC) AS prod_comp_rank
FROM movie m
	INNER JOIN ratings r
    ON m.id = r.movie_id
GROUP BY production_company
)
SELECT * FROM top_3_company
WHERE prod_comp_rank <=3;

-- Marvel studios is on top with the vote count of 2656967

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT name AS actor_name, SUM(total_votes) AS total_votes, COUNT(r.movie_id) AS movie_count,
	   ROUND(SUM(total_votes * avg_rating)/SUM(total_votes),2) AS actor_avg_rating, 
       RANK() OVER (ORDER BY ROUND(SUM(total_votes * avg_rating)/SUM(total_votes),2) DESC, SUM(total_votes) DESC) AS actor_rank
FROM names n
	INNER JOIN role_mapping rm
    ON n.id = rm.name_id
		INNER JOIN movie m
        ON rm.movie_id = m.id 
			INNER JOIN ratings r
            ON r.movie_id = rm.movie_id
WHERE country = 'India' AND category = 'ACTOR'
GROUP BY n.name
HAVING movie_count >= 5;

-- Top actor is Vijay Sethupathi with the acvg rating of 8.42 and total vote count of 23114
/* Although Yogi Babu is in the top 3, but he has acted in 11 movies but having the vote vount of only 8500 as compared To Fahaad fasil 
   who has movie_count of 5 but the total votes being 13557 */

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_5_actress AS (
SELECT name AS actress_name, SUM(total_votes) AS total_votes, COUNT(rm.movie_id) AS movie_count,
	   ROUND(SUM(total_votes * avg_rating)/SUM(total_votes),2) AS actress_avg_rating, 
       RANK() OVER (ORDER BY ROUND(SUM(total_votes * avg_rating)/SUM(total_votes),2) DESC, SUM(total_votes) DESC) AS actress_rank
FROM names n
	INNER JOIN role_mapping rm
    ON n.id = rm.name_id
		INNER JOIN movie m
        ON m.id = rm.movie_id
			INNER JOIN ratings r
            ON r.movie_id = m.id
WHERE country = 'India' AND languages = 'Hindi' AND category = 'ACTRESS'
GROUP BY name
HAVING movie_count >= 3
)
SELECT * FROM top_5_actress
WHERE actress_rank <=5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT title,avg_rating, CASE  WHEN avg_rating > 8 THEN 'Superhit movies'
				    WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
                    WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch-movies'
                    ELSE 'Flop movies' END AS Popularity
FROM movie m
	INNER JOIN ratings r
    ON m.id = r.movie_id
		INNER JOIN genre g
        ON m.id = g.movie_id
WHERE genre = 'Thriller'
ORDER BY avg_rating DESC;
                    
/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH genre_avg AS (
SELECT genre, AVG(duration) AS avg_duration
FROM genre AS g
	INNER JOIN movie AS m
	ON g.movie_id = m.id
GROUP BY genre
ORDER BY AVG(duration)
)
SELECT genre, ROUND(avg_duration,2) AS avg_duration, ROUND(SUM(avg_duration) OVER (ORDER BY avg_duration),2) AS running_total_duration,
	   ROUND(AVG(avg_duration) OVER (ORDER BY avg_duration),2) AS moving_avg_duration
FROM genre_avg;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top_3_genres AS (
SELECT genre FROM (
SELECT genre, RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS gn_rank
FROM genre
GROUP BY genre
) AS abc
WHERE gn_rank <=3),
top_5_movies AS (
SELECT genre, year,title AS movie_name,CASE
											WHEN m.worlwide_gross_income LIKE 'INR%' THEN ROUND(SUBSTRING(m.worlwide_gross_income, 4) / 80, 2)
											ELSE ROUND(SUBSTRING(m.worlwide_gross_income,4),2)
											END AS worldwide_gross_income
FROM genre g
	INNER JOIN movie m
    ON g.movie_id = m.id
WHERE genre in (SELECT * FROM top_3_genres)
),
top_movies AS (
SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY worldwide_gross_income DESC) AS movie_rank
FROM top_5_movies
), 
final_table AS (
SELECT * FROM top_movies
WHERE movie_rank <=5
ORDER BY year, movie_rank
)
SELECT genre,year,movie_name, CONCAT('$ ',worldwide_gross_income) AS worldwide_gross_income, movie_rank FROM (
				SELECT *,ROW_NUMBER() OVER (PARTITION BY year, movie_name ORDER BY worldwide_gross_income DESC) AS rnk
                FROM final_table) AS intermediate_table
WHERE rnk =1;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH top_2_movies AS (
SELECT production_company, COUNT(movie_id) AS movie_count, DENSE_RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS prod_comp_rank
FROM movie m 
	INNER JOIN ratings r
    ON m.id = r.movie_id
WHERE median_rating >=8 AND languages REGEXP '.*,'
GROUP BY production_company
HAVING production_company IS NOT NULL
)
SELECT * FROM top_2_movies
WHERE prod_comp_rank <=2;

-- Star cinema has the highest number of hit movies in multilanguage that is 7 followed by Twentieth Century Fox with the movie count of 4


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_3_actress AS (
SELECT name AS actress_name, SUM(total_votes) AS total_votes, COUNT(r.movie_id) AS movie_count, ROUND(AVG(avg_rating),2) AS actress_avg_rating,
			   RANK() OVER (ORDER BY COUNT(movie_id) DESC, ROUND(AVG(avg_rating),2) DESC, SUM(total_votes) DESC) AS actress_rank
FROM role_mapping r
	INNER JOIN names n
    ON r.name_id = n.id
		INNER JOIN ratings rt
        ON r.movie_id = rt.movie_id
			INNER JOIN genre g
            ON r.movie_id = g.movie_id
WHERE category = 'actress' AND genre = 'DRAMA' AND avg_rating > 8
GROUP BY name
)
SELECT * FROM top_3_actress
WHERE actress_rank <=3;

-- Susan Brown, Amanda Lawrence and Denise Gough are the top 3 actress having highest number of super hit movies

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH top_director_summary AS (
WITH top_directors AS (
SELECT name_id, name, dm.movie_id, 
	   avg_rating, total_votes,m.date_published, 
       LEAD(date_published) OVER (PARTITION BY dm.name_id ORDER BY date_published,dm.movie_id) AS next_movie_published,
       duration
FROM director_mapping dm
	INNER JOIN names n
    ON dm.name_id = n.id
		INNER JOIN ratings r
        ON dm.movie_id = r.movie_id
			INNER JOIN movie m
            ON dm.movie_id = m.id
            )
SELECT name_id AS director_id, name AS director_name, COUNT(movie_id) AS number_of_movies,
	   ROUND(AVG(DATEDIFF(next_movie_published,date_published)),2) AS avg_inter_movie_days, ROUND(AVG(avg_rating),2) AS avg_rating,
	   Round(sum(avg_rating*total_votes)/sum(total_votes), 2) AS avg_ratings,SUM(total_votes) AS total_votes,
       MIN(avg_rating) AS min_rating,MAX(avg_rating) AS max_rating,
       SUM(duration) AS total_duration, RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS movie_rank
FROM top_directors
GROUP BY name_id
)
SELECT director_id,
	   director_name,
       number_of_movies,
       avg_inter_movie_days,
       avg_ratings,
       total_votes,
       min_rating,
       max_rating,
       total_duration
FROM top_director_summary
WHERE movie_rank <=9;