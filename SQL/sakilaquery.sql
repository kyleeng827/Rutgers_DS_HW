use sakila;
select * from actor;
-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name 
from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case 
-- letters. Name the column `Actor Name`.
select concat(upper(first_name), " ", upper(last_name)) as actor_name
from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you 
-- know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor
where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the 
-- rows by last name and first name, in that order:
select * from actor
where last_name like '%LI%'
order by last_name asc, first_name asc;
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following 
-- countries: Afghanistan, Bangladesh, and China:
select * from country;
select * from country
where country in ('Afghanistan', 'Bangladesh', 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing 
-- queries on a description, so create a column in the table `actor` named `description` 
-- and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference 
-- between it and `VARCHAR` are significant).
alter table actor
add description blob;
select* from actor;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much 
-- effort. Delete the `description` column.
alter table actor
drop column description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) 
from actor
group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but 
-- only for names that are shared by at least two actors.
select last_name, count(*) 
from actor
group by last_name
having count(*)>=2;
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
-- `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor
set first_name = 'HARPO' 
where first_name = "GROUCHO" AND last_name = "WILLIAMS";
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that 
-- `GROUCHO` was the correct name after all! In a single query, if the first name of 
-- the actor is currently `HARPO`, change it to `GROUCHO`.
SET SQL_SAFE_UPDATES = 0;
select actor_id from actor
where first_name = 'HARPO' and last_name='WILLIAMS';
update actor
set first_name = 
	case 
		when first_name = "HARPO"
			then "GROUCHO"
	end
where actor_id = 172;
-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each 
-- staff member. Use the tables `staff` and `address`:
select * from staff;
select * from address;
select staff.first_name, staff.last_name, address.address
from staff
left join address on staff.address_id=address.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 
-- 2005. Use tables `staff` and `payment`.
select * from payment;
select s.staff_id, s.first_name, s.last_name, sum(payment.amount)
from staff s
inner join payment on s.staff_id = payment.staff_id
where payment.payment_date like "2005-08%"
group by s.staff_id;
-- 6c. List each film and the number of actors who are listed for that film. Use 
-- tables `film_actor` and `film`. Use inner join.
select * from film_actor; -- actor_id, film_id
select * from film;
select count(fa.actor_id), f.title
from film_actor fa
inner join film f on fa.film_id = f.film_id
group by f.title;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select * from inventory;
select count(film_id)
from inventory
where film_id in (
	select film_id
    from film
    where title = "HUNCHBACK IMPOSSIBLE"
    );
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the 
-- total paid by each customer. List the customers alphabetically by last name:
select * from customer;
select c.first_name, c.last_name, sum(payment.amount)
from customer c
inner join payment on c.customer_id = payment.customer_id
group by c.customer_id
order by c.last_name asc;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies starting 
-- with the letters `K` and `Q` whose language is English.
select * from language;
select title, language_id
from film
where title like 'K%' or title like 'Q%' and language_id in 
	(
	select language_id
    from language
    where name = 'English'
    );
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select * from actor;
select * from film;
select * from film_actor;
select first_name, last_name 
from actor
where actor_id in 
	(
	select actor_id
    from film_actor
    where film_id in 
		(
		select film_id
        from film
        where title = 'ALONE TRIP'
        )
	);
-- 7c. You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. Use joins to retrieve this 
-- information.
select * from customer; -- first_name, last_name, email, address_id
select * from address; -- address_id, city_id
select * from city; -- city_id, country_id
select * from country; -- country_id, country
select first_name, last_name, email
from customer
where address_id in 
	(
    select address_id
    from address
    where city_id in 
		(
        select city_id
        from city
        where country_id in 
			(
            select country_id
            from country
            where country = "Canada"
            )
		)
	);
-- 7d. Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as _family_ films.
select * from film; -- title, film_id
select * from film_category; -- film_id, category_id
select * from category; -- category_id, name
select title
from film
where film_id in
	(
    select film_id
    from film_category
    where category_id in
		(
        select category_id
        from category
        where name = "family"
        )
	);
-- 7e. Display the most frequently rented movies in descending order.
select * from film; -- description, film_id
select * from inventory; -- film_id, inventory_id
select * from rental; -- rental_id, inventory_id
select title, count(rental.rental_id)
from film
right join inventory on film.film_id = inventory.inventory_id
join rental on rental.inventory_id = inventory.inventory_id
group by film.title
order by count(rental.rental_id) desc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store; -- store_id
select * from payment; -- payment_id, customer_id, staff_id, rental_id, amount
select * from staff; -- staff_id, store_id
select store.store_id, sum(payment.amount)
from store
inner join staff on store.store_id = staff.store_id
inner join payment on staff.staff_id = payment.staff_id
group by store.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
Select * from store; -- store_id, address_id
select * from address; -- address_id, city_id
select * from city; -- city, city_id, country_id
select * from country; -- country_id, country
select store_id, city.city, country.country
from store
inner join address on store.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id;
-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, 
-- inventory, payment, and rental.)
select * from category; -- name, category_id
select * from film_category; -- film_id, category_id
select * from inventory; -- film_id
select * from payment; -- rental_id, amount
select * from rental; -- rental_id
select category.name, sum(payment.amount)
from category
inner join film_category
on category.category_id = film_category.category_id
inner join inventory
on film_category.film_id = inventory.film_id
inner join rental
on rental.inventory_id = inventory.inventory_id
inner join payment
on payment.rental_id = rental.rental_id
group by name;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above to create 
-- a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_5_by_genre as
select category.name, sum(payment.amount)
from category
inner join film_category
on category.category_id = film_category.category_id
inner join inventory
on film_category.film_id = inventory.film_id
inner join rental
on rental.inventory_id = inventory.inventory_id
inner join payment
on payment.rental_id = rental.rental_id
group by name
limit 5;

            





