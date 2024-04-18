-- Uneven workloads.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	assignment_id integer NOT NULL,
	username varchar(25) NOT NULL,
	num_assigned integer NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS num_assigned_by_username CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW num_assigned_by_username AS
select assignment_id, username, count(group_id) num_assigned
from AssignmentGroup natural join Grader
group by assignment_id, username;

CREATE VIEW ranges AS
select assignment_id, 
		(max(num_assigned) - min(num_assigned)) a_range
from (select * from num_assigned_by_username) n
group by assignment_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
select assignment_id, username, num_assigned
from (select * from num_assigned_by_username) n
	natural join (select * from ranges) r
where r.a_range > 10;