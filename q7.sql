-- High coverage.

SET search_path TO markus;
DROP TABLE IF EXISTS q7 CASCADE;

CREATE TABLE q7 (
	grader varchar(25) NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS first_condition CASCADE;
DROP VIEW IF EXISTS second_condition CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW first_condition AS 
	SELECT username
	FROM (Grader AS G join AssignmentGroup AS AG on G.group_id = AG.group_id) join assignment on assignment.assignment_id = AG.assignment_id
	GROUP BY username
	Having count(DISTINCT AG.assignment_id) = (Select count(distinct assignment_id) from Assignment);


CREATE VIEW second_condition AS
	SELECT Grader.username
	FROM Grader join Membership on Membership.group_id = Grader.group_id
	GROUP BY Grader.username
	Having count(DISTINCT Membership.username) = (Select count(distinct username) from Membership);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q7
	SELECT DISTINCT username
	FROM first_condition
	INTERSECT
	SELECT DISTINCT username
	FROM second_condition;