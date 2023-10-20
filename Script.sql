--Requete A

select first_name
FROM actor;

--Requete B

select last_name
FROM actor;

--Liste des titres de films

SELECT title
FROM film f;

--Nombre de films par catégorie

SELECT name , count(film_id)
from film_category fc 
Join category c 
on fc.category_id = c.category_id 
GROUP BY fc.category_id;

--Liste des films dont la durée est supérieure à 120 minutes

SELECT title , length
FROM film
WHERE length > 120

--Liste des films de catégorie "Action" ou "Comedy"

SELECT title, name
FROM film_category fc 
JOIN film f
ON fc.film_id = f.film_id 
JOIN category c 
ON fc.category_id = c.category_id 
WHERE name = 'Action' or name = "Comedy"
ORDER BY name;

--Nombre total de films (définissez l'alias 'nombre de film' pour la valeur calculée)

SELECT COUNT(title) AS "Nombre de film"
FROM film f ;

--Les notes moyennes par catégorie

SELECT name, count(title), AVG(rental_rate)
FROM film_category fc 
JOIN film f 
ON fc.film_id = f.film_id
JOIN category c 
ON fc.category_id = c.category_id 
GROUP BY name;

-----------------------------------------------
-----------------------------------------------


--Les 10 films les plus loués
SELECT title, count(customer_id) AS "loueur"
FROM inventory i 
JOIN film f 
ON i.film_id = f.film_id 
JOIN rental r 
ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY "loueur" desc
LIMIT 10;

--Acteurs ayant joué dans le plus grand nombre de films
SELECT first_name , last_name, count(title) AS "somme des films"
FROM film_actor fa 
JOIN actor a 
ON fa.actor_id = a.actor_id 
JOIN film f 
ON fa.film_id = f.film_id
GROUP BY fa.actor_id  
ORDER BY "somme des films" DESC
LIMIT 10;


----Revenu total généré par mois 
SELECT STRFTIME("%Y", payment_date) AS YEAR,
STRFTIME('%m', payment_date) AS MOIS,
sum(amount) AS TOTAL
FROM payment
GROUP BY STRFTIME("%m", payment_date)
ORDER BY STRFTIME("%Y", payment_date) DESC;


----Revenu total généré par chaque magasin par mois pour l'année 2005. 
SELECT STRFTIME("%Y", payment_date) AS YEAR,
	STRFTIME('%m', payment_date) AS MOIS,
	sum(amount) AS TOTAL,
	s.store_id 
FROM payment
JOIN rental r ON payment.rental_id = r.rental_id 
JOIN customer c ON r.customer_id = c.customer_id 
JOIN store s ON c.store_id = s.store_id 
WHERE STRFTIME("%Y", payment_date) LIKE "2005%"
GROUP BY STRFTIME("%m", payment_date), s.store_id
ORDER BY STRFTIME("%Y", payment_date) DESC;


--Les clients les plus fidèles, basés sur le nombre de locations.
SELECT first_name, last_name, count(rental_date) AS "Nombre de locations"
FROM customer c 
JOIN rental r 
ON c.customer_id = r.customer_id
GROUP BY c.customer_id  
ORDER BY "Nombre de locations" DESC
limit 20;



--Films qui n'ont pas été loués au cours des 6 derniers mois. 
SELECT title, rental_date
FROM film f 
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental ON i.inventory_id = rental.inventory_id 
WHERE rental_date IS NOT NULL
GROUP BY title
ORDER BY DATE('now', '-6 months') ASC;



--Le revenu total de chaque membre du personnel à partir des locations.
SELECT first_name, sum(amount)
FROM payment p
JOIN staff ON p.staff_id = staff.staff_id
GROUP BY staff.staff_id;



--Catégories de films les plus populaires parmi les clients.
SELECT name, count(customer_id) AS "loueur"
FROM inventory i 
JOIN film f 
ON i.film_id = f.film_id 
JOIN rental r 
ON i.inventory_id = r.inventory_id
JOIN film_category fc 
ON f.film_id = fc.film_id
JOIN category c 
ON fc.category_id  = c.category_id 
GROUP BY c.category_id 
ORDER BY "loueur" desc;

--------------------------------------------------

SELECT name, count(r.rental_id) AS "location"
FROM inventory i 
JOIN film f 
ON i.film_id = f.film_id 
JOIN rental r 
ON i.inventory_id = r.inventory_id
JOIN film_category fc 
ON f.film_id = fc.film_id
JOIN category c 
ON fc.category_id  = c.category_id 
GROUP BY c.category_id 
ORDER BY "location" desc;

--Durée moyenne entre la location d'un film et son retour.
SELECT AVG(CAST(JULIANDAY(return_date) - JULIANDAY(rental_date) AS INTEGER)) AS "Durée moyenne de location"
FROM rental r;


--Acteurs qui ont joué ensemble dans le plus grand nombre de films. 

SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, COUNT() AS "nombre_de_films"
FROM film_actor AS fa1
JOIN film_actor AS fa2 ON fa1.film_id = fa2.film_id
JOIN actor AS a1 ON fa1.actor_id = a1.actor_id
JOIN actor AS a2 ON fa2.actor_id = a2.actor_id
WHERE a1.actor_id < a2.actor_id
GROUP BY a1.actor_id, a2.actor_id
ORDER BY nombre_de_films DESC;

------------------------------------------
------------------------------------------

SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, COUNT() AS "nombre_de_films"
  FROM film_actor AS fa1
  JOIN film_actor AS fa2 ON fa1.film_id = fa2.film_id
						AND a1.actor_id < a2.actor_id
  JOIN actor AS a1       ON fa1.actor_id = a1.actor_id
  JOIN actor AS a2       ON fa2.actor_id = a2.actor_id
 WHERE a1.first_name LIKE "a%"
 GROUP BY a1.actor_id, a2.actor_id
 ORDER BY nombre_de_films DESC;

--Bonus : Clients qui ont loué des films mais n'ont pas fait au moins une location dans les 30 jours qui suivent.


WITH intervalle_location AS (
SELECT  r1.rental_date as R1_date, r2.rental_date as R2_date, (JULIANDAY(DATE(r2.rental_date)) - JULIANDAY(DATE(r1.rental_date))) as diff_date , r1.customer_id 
FROM rental r1
JOIN rental r2 ON r1.customer_id  = r2.customer_id AND DATE(r2.rental_date) > DATE(r1.rental_date )
WHERE r2.rental_date NOT BETWEEN DATE(r1.rental_date, '+30 days') AND r1.rental_date AND STRFTIME("%Y-%m",r1.rental_date) ="2005-08"
ORDER BY diff_date)
SELECT * 
FROM intervalle_location as il
GROUP BY il.customer_id 
HAVING diff_date > 30;






-----------Bonus altérer votre BDD avec les requêtes suivantes

--Ajoutez un nouveau film dans la base de données.
--INSERT INTO film (title, release_year, length)
--VALUES ("Sunset Odyssey", 2023, 125);


--Mettez à jour le film intitulé "Sunset Odyssey" pour qu'il appartienne à la catégorie "Adventure".



--DELETE FROM film WHERE title = 'Sunset Odyssey';



	


