-- A1 report.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q10 CASCADE;

CREATE TABLE q10 (
	group_id bigint NOT NULL,
	mark real DEFAULT NULL,
	compared_to_average real DEFAULT NULL,
	status varchar(5) DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS A1groups CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW A1groups AS 
	SELECT mark, A1gs.group_id as group_id
	FROM(
	SELECT group_id
	FROM (AssignmentGroup AS AG join(
	SELECT assignment_id as AS_id
	FROM Assignment
	WHERE description = 'A1') as A1 on AG.assignment_id = AS_id
	)) AS A1gs LEFT JOIN (
	SELECT R.group_id as group_id, 100 * mark / weighted_sum as mark
	FROM Result AS R join (
		SELECT group_id, sum(weight) as weighted_sum
		FROM RubricItem AS RI join Grade as G on RI.rubric_id = G.rubric_id
		GROUP BY group_id ) AS Ws on R.group_id = Ws.group_id
	) AS P ON P.group_id = A1gs.group_id;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10
	SELECT group_id, mark, mark - AVG(mark) OVER () AS compared_to_average, 
	CASE	
		WHEN mark > AVG(mark) OVER () THEN 'above'
        WHEN mark = AVG(mark) OVER () THEN 'at'
        WHEN mark < AVG(mark) OVER () THEN 'below'
		ELSE NULL
    END AS status
	FROM A1groups; 
