-- Inseparable.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q9 CASCADE;

CREATE TABLE q9 (
	student1 varchar(25) NOT NULL,
	student2 varchar(25) NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS multi_groups CASCADE;
DROP VIEW IF EXISTS group_mates CASCADE;

CREATE VIEW multi_groups AS 
	SELECT group_id
	FROM AssignmentGroup
	RIGHT JOIN (
	SELECT assignment_id
	FROM assignment
	WHERE group_max > 1
	) AS A ON AssignmentGroup.assignment_id = A.assignment_id;

-- Define views for your intermediate steps here:
CREATE VIEW group_mates AS 
	SELECT A1.username AS student1, A2.username AS student2, A1.group_id AS group
	FROM Membership A1 JOIN Membership A2 ON  A1.username < A2.username 
	WHERE A1.group_id = A2.group_id
	AND NOT EXISTS (
		SELECT 1
		FROM Membership AS A3
		WHERE A3.username = A1.username
		AND A3.group_id NOT IN (A1.group_id, A2.group_id)
	)
	AND NOT EXISTS (
		SELECT 1
		FROM Membership AS A4
		WHERE A4.username = A2.username
		AND A4.group_id NOT IN (A1.group_id, A2.group_id)
	);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
	SELECT student1, student2
	FROM multi_groups JOIN group_mates on multi_groups.group_id = group_mates.group;
