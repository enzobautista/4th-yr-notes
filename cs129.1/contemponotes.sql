sh reload_book_db.sh enzo db1

Aggregate Functions
	min()
	max()
	count()

	Get the earliest date of all events
	Get the latest date of all events

	SELECT min(starts), max(ends) 
	FROM events INNER JOIN venues
	ON events.venue_id=venues.venue_id
	WHERE venues.name='Shoe Museum';

	SELECT min(extract(month from starts)) earliest_month, 
	max(extract(month from ends)) latest_month,
	max(extract(day from ends)) latest_day 
	FROM events INNER JOIN venues
	ON events.venue_id=venues.venue_id
	WHERE venues.name='Shoe Museum';

	--number of all events for venue_id
	SELECT count(*) FROM events WHERE venue_id=1;
	SELECT count(*) FROM events WHERE venue_id=1;

	--number of events for each venues by venue_id
	SELECT venue_id, count(*) FROM events
	GROUP BY venue_id;

	--number of events for each venues
	--venue.name | number of events
	SELECT venues.name, count(*)
	FROM events JOIN venues
	ON events.venue_id=venues.venue_id
	GROUP BY venues.venue_id
	HAVING count(*) >=2;

	--venues.name | events.title | number_of_events_per_venue
	SELECT venues.name, events.title, count(*)
	FROM events JOIN venues
	ON events.venue_id=venues.venue_id
	GROUP BY venues.venue_id, events.title;

	--partitions
	SELECT venues.name, events.title, count(*)
	OVER (PARTITION BY events.venue_id)
	FROM events JOIN venues
	ON events.venue_id=venues.venue_id;

	--GROUP by collapses common data
	--PARTITION groups common data

--Assumes that country is existing
add_event(
	title text,
	starts timestamp,
	venue text,
	postal varchar(9),
	country char(2)
)

--
SELECT add_event(
	'Philippine National Fireworks Festival 2016',
	'2016-04-30 19:00',
	'2016-04-30 23:00',
	'Riverbanks Center Amphitheater',
	'1801',
	'ph'
);
--TRIGGERS
--If an event has been updated, log that activity

--Create logs table
CREATE TABLE logs (
	event_id integer,
	old_title varchar(255),
	old_starts timestamp,
	old_ends timestamp,
	logged_at timestamp DEFAULT current_timestamp
	);

\i log_event.sql	

--Vertical scaling
	>relational database uses vertical scaling
	>Lookup table relates the tables together via the reference venue_id
	>relationship between tables
	>join is a concatenation of multiple tables
--O(1) -> Index
--O(logn) -> Btrees

--Horizontal scaling
	>Maintain just one record for 'customer' (think of that record as a folder)
	>One to Many can be implemented as an array that belongs to an entity

--Meta Data
	>Json
		<key, value>
		>object that will hold data
		>can hold arrays in []
		>has keys
		>keys always have values either strings or objects
		>starts and ends with {}
	>XML
	>these allow to scale since they allow a single object to contain children records
--CS 129.1 Notes Sept 30, 2016
--1.) How to insert a json object into our postgres database tables
--2.)SELECT -> nested attributes
--3.) SELECT -> nested arrays
-------------------------
| ID | INFO (Text) (json|
| 1  |  {     }         |
| 2  |  {     }         |
-------------------------

--create table that contains json
CREATE TABLE customers(
ID serial NOT NULL PRIMARY KEY,
info json NOT NULL
);

--insert
INSERT INTO customers (info) VALUES ('{
	"first_name": "Foo",
	"last_name": "Bar",
	"address": {
		"street_number": "1102",
		"street_name": "Katipunan",
		"city": "Quezon City",
		"region": "NCR"
	},
	"orders": [
		{
			"item": "Apple",
			"price": 100
		},
		{
			"item": "Pen",
			"price": 200
		}
	]
}');

--
SELECT * FROM customers;
--
SELECT info from customers;
--how to query nested attributes
SELECT info -> 'address' -> 'city' FROM customers;
--
SELECT info -> 'city' FROM customers;
--
--SELECT info i, ^Cson_array_elements(i.in) FROM customers; nvm this
--
SELECT * FROM customers c, json_array_elements(c.info->'orders');
--give me all the results fro the customer table where from the info column i am expecting a key in info called orders, and use elem to represent that 'item' with the key item
SELECT * FROM customers c, json_array_elements(c.info->'orders') AS elem where elem->>'item'='Pen';
