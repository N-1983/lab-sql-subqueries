lab 3.03
-- How many copies of the film Hunchback Impossible exist in the inventory system?
USE sakila1;
SELECT inventory_id,film_id;


SELECT COUNT(*) 
FROM sakila1.inventory
  WHERE film_id IN (
    SELECT film FROM (
      SELECT title, film_id FROM sakila1.film
      WHERE title LIKE 'Hunchback Impossible') sub1
 );
 
 -- List all films whose length is longer than the average of all the films.
SELECT title FROM sakila1.film
  WHERE length > (
  SELECT AVG(length) AS average FROM sakila1.film
 );
 
 -- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name FROM actor
WHERE actor_id IN(
	SELECT actor_id from (
		SELECT actor_id, film_id FROM sakila1.film_actor
		WHERE film_id IN (
			SELECT film_id from (
			SELECT title, film_id FROM sakila1.film
				WHERE title LIKE 'Alone Trip'
				) sub1
			)
		)sub2
	);
    
    -- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film_id, title FROM sakila1.film 
WHERE film_id IN(
	SELECT film_id FROM sakila1.film_category 
	WHERE category_id IN(
		SELECT category_id FROM sakila1.category 
		WHERE name LIKE 'Family'
		)
	);
    
    -- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
  SELECT first_name,last_name,email FROM sakila1.customer 
WHERE  address_id IN(
	SELECT address_id FROM sakila1.address 
		WHERE address_id IN(
			SELECT city_id FROM sakila1.city 
                WHERE country_id IN(
                    SELECT country_id FROM sakila1.country 
                     WHERE country LIKE 'Canada')
				)
             );
-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.   
  SELECT title FROM sakila1.film
WHERE film_id IN (
	SELECT film_id FROM sakila1.film_actor
	WHERE actor_id IN(
	SELECT actor_id FROM(
			SELECT actor_id, COUNT(film_id) AS num_films
			FROM sakila1.actor
			JOIN film_actor
			USING (actor_id)
			GROUP BY actor_id
			ORDER BY num_films DESC
			LIMIT 1) sub1
			)
            );  
    
    


-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
  SELECT c.first_name, c.last_name, sum(p.amount) AS profitable_customer FROM sakila1.customer c  
    JOIN payment p 
    ON c.customer_id = p.customer_id
    GROUP BY c.last_name, c.first_name
    ORDER BY profitable_customer DESC;
    
-- Customers who spent more than the average payments.
    
    
 SELECT first_name, last_name
FROM customer
	WHERE customer_id IN (
	SELECT customer_id
        FROM (SELECT sp.customer_id, SUM(amount) AS spent_amount
            FROM sakila1.payment sp
            GROUP BY customer_id
            HAVING spent_amount > (SELECT 
								AVG(spent_amount) avg_spent_amount
								FROM (SELECT sp.customer_id, SUM(amount) AS spent_amount
								FROM sakila1.payment sp
								GROUP BY customer_id) sub1)
                                )sub2
                                );  