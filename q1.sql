-- Distributions.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
	assignment_id integer NOT NULL,
	average_mark_percent real DEFAULT NULL,
	num_80_100 integer NOT NULL,
	num_60_79 integer NOT NULL,
	num_50_59 integer NOT NULL,
	num_0_49 integer NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW intermediate_step AS
SELECT assignment_id, group_id, (max(mark)*100/sum(weight)) mark_percentage
FROM 
	Assignment NATURAL FULL JOIN 
	AssignmentGroup NATURAL FULL JOIN
	RubricItem NATURAL FULL JOIN
	Result
GROUP BY assignment_id, group_id;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT assignment_id,
AVG(mark_percentage),
COUNT(CASE WHEN mark_percentage <= 100 and mark_percentage >= 80 THEN group_id END) AS num_80_100,
COUNT(CASE WHEN mark_percentage < 80 and mark_percentage >= 60 THEN group_id END) AS num_60_79,
COUNT(CASE WHEN mark_percentage < 60 and mark_percentage >= 50 THEN group_id END) AS num_50_59,
COUNT(CASE WHEN mark_percentage < 50 and mark_percentage >= 0 THEN group_id END) AS num_0_49
FROM (SELECT * FROM intermediate_step) as I
GROUP BY assignment_id;
