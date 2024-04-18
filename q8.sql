-- Never solo by choice.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q8 CASCADE;

CREATE TABLE q8 (
	username varchar(25) NOT NULL,
	group_average real NOT NULL,
	solo_average real DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS multi_groups CASCADE;
DROP VIEW IF EXISTS one_file CASCADE;
DROP VIEW IF EXISTS percentages CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW multi_groups AS 
	SELECT distinct M1.username 
	FROM (
		SELECT Groups.group_id, username FROM Membership JOIN 
		(SELECT group_id
		FROM AssignmentGroup
		RIGHT JOIN (
			SELECT assignment_id
			FROM assignment
			WHERE group_max > 1
		) AS A ON AssignmentGroup.assignment_id = A.assignment_id
		) AS Groups ON Groups.group_id = Membership.group_id) as M1 join Membership AS M2 ON M1.group_id = m2.group_id AND M1.username != M2.username; 

CREATE VIEW one_file AS
	SELECT distinct username
	FROM AssignmentGroup AS AG right join (
		SELECT username, group_id
		FROM Submissions
	) AS subs on AG.group_id = subs.group_id 
	GROUP by username
	HAVING count(distinct assignment_id) = (Select count(distinct assignment_id) from Assignment);

CREATE VIEW percentages AS
	SELECT P.group_id as group_id, mark, username 
	FROM (
	SELECT R.group_id as group_id, 100 * mark / weighted_sum as mark
	FROM Result AS R join (
		SELECT group_id, sum(weight) as weighted_sum
		FROM RubricItem AS RI join Grade as G on RI.rubric_id = G.rubric_id
		GROUP BY group_id
	) AS Ws on R.group_id = Ws.group_id
	) AS P join ( 
	SELECT M.username, group_id
	FROM (one_file NATURAL JOIN multi_groups) as studs join Membership as M on M.username = studs.username
	) AS groups ON P.group_id = groups.group_id;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q8
	SELECT username, AVG(CASE WHEN A.group_max > 1 THEN AGS.mark ELSE NULL END) as group_average,
	AVG(CASE WHEN A.group_max = 1 THEN AGS.mark ELSE NULL END) as solo_average
	FROM (percentages AS P join AssignmentGroup AS AG on P.group_id = AG.group_id) AS AGS join Assignment AS A on AGS.assignment_id = A.assignment_id
	GROUP BY username;
	
