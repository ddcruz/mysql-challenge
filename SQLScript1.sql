use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT a.first_name
	, a.last_name
FROM actor a;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. 
Name the column Actor Name.*/
SELECT UCASE(CONCAT(a.first_name, ' ',  a.last_name)) AS 'Actor Name'
FROM actor a;

/* 2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
*/
SELECT a.actor_id
	, a.first_name
    , a.last_name
FROM actor a
WHERE a.first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT a.actor_id
	, a.first_name
    , a.last_name
FROM actor a
WHERE a.last_name LIKE '%GEN%';

/* 2c. Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order:
*/
SELECT a.actor_id
	, a.first_name
    , a.last_name
FROM actor a
WHERE a.last_name LIKE '%LI%'
ORDER BY a.last_name
	, a.first_name;
    
/* 2d. Using IN, display the country_id and country columns of the following 
countries: Afghanistan, Bangladesh, and China
*/    
SELECT c.country_id
	, c.country
FROM country c
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');

/* 3a. You want to keep a description of each actor. 
You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB 
(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
*/
ALTER TABLE actor
ADD COLUMN description BLOB NULL AFTER last_name;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
Delete the description column.
*/
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT a.last_name, COUNT(a.last_name) AS 'Count of actors'
FROM actor a
GROUP BY a.last_name;

/* 4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors
*/
SELECT a.last_name, COUNT(a.last_name) AS 'Count of actors shared by at least two actors'
FROM actor a
GROUP BY a.last_name
HAVING COUNT(a.last_name) >= 2;

/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
Write a query to fix the record.
*/
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, 
if the first name of the actor is currently HARPO, change it to GROUCHO.
*/
UPDATE actor 
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO'
LIMIT 1;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
Use the tables staff and address:
*/
SELECT s.first_name
	, s.last_name
    , a.address
    , a.address2
    , a.district
    , c.city
    , a.postal_code
FROM staff s
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id;

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment
*/
SELECT s.staff_id
	, s.first_name
    , s.last_name 
    , SUM(p.amount) as 'Total Amount'
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
WHERE YEAR(p.payment_date) = 2005
AND MONTH(p.payment_date) = 8
GROUP BY s.staff_id
	, s.first_name
    , s.last_name;
    
/* 6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join.
*/
SELECT f.title
	, COUNT(fa.actor_id) AS 'number of actors'
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;

/* 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
*/
SELECT COUNT(i.inventory_id) AS 'copies of the film Hunchback Impossible'
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each 
customer. List the customers alphabetically by last name:
*/
SELECT c.customer_id
	, c.first_name
	, c.last_name
    , SUM(p.amount) as 'total paid by each customer'
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
	, c.first_name
	, c.last_name
ORDER BY c.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also 
soared in popularity. Use subqueries to display the titles of movies starting with 
the letters K and Q whose language is English.
*/
SELECT f.title
FROM film f
WHERE f.film_id IN (
	SELECT f.film_id
	FROM film f
	WHERE f.title LIKE 'K%'
	OR f.title LIKE 'Q%'
    ) 
AND f.language_id IN (
	SELECT l.language_id
	FROM language l
	WHERE l.name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id 
	, first_name
	, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
    WHERE film_id IN (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
    )
);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the
 names and email addresses of all Canadian customers. Use joins to retrieve this information.
*/
SELECT c.first_name
	, c.last_name
    , c.email
    , c2.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city c1 ON a.city_id = c1.city_id
JOIN country c2 ON c1.country_id = c2.country_id AND c2.country = 'Canada';

/*  7d. Sales have been lagging among young families, and you wish to target all 
family movies for a promotion. Identify all movies categorized as family films.
*/
SELECT c.name as genre
	, f.film_id
    , f.title
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id 
INNER JOIN category c ON fc.category_id = c.category_id AND c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title as movie
	, COUNT(i.film_id) as 'count of rentals'
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(i.film_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s1.store_id
	, concat('$', format(SUM(p.amount), 2)) as total_business
FROM payment p
INNER JOIN staff s ON p.staff_id = s.staff_id
INNER JOIN store s1 ON s.store_id = s1.store_id
GROUP BY s1.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id
	, c.city
    , c1.country
FROM store s
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city c ON c.city_id = a.city_id
INNER JOIN country c1 ON c.country_id = c1.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*/
SELECT c.name as genre
	, concat('$', format(SUM(p.amount), 2)) AS gross_revenue
FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the 
Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.
*/
CREATE VIEW top_five_genres_by_gross_revenue AS 
SELECT c.name as genre
	, concat('$', format(SUM(p.amount), 2)) AS gross_revenue
FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres_by_gross_revenue;