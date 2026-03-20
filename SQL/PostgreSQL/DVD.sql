SELECT a.district,c.email 
FROM address a
LEFT JOIN customer c
ON c.address_id = a.address_id 
WHERE a.district = 'California'


SELECT f.title,a.first_name,a.last_name 
FROM film f
LEFT JOIN film_actor fa
ON f.film_id = fa.film_id
LEFT JOIN actor a 
ON a.actor_id = fa.actor_id
WHERE a.first_name = 'Nick' AND a.last_name  = 'Wahlberg'


