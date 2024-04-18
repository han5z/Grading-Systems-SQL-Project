-- Grader report.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	assignment_id integer NOT NULL,
	username varchar(25) NOT NULL,
	num_marked integer NOT NULL,
	num_not_marked integer NOT NULL,
	min_mark real DEFAULT NULL,
	max_mark real DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS maxmin CASCADE;


-- Define views for your intermediate steps here:
create view maxmin as
select assignment_id, group_id, username,
(min(mark)*100/sum(weight)) min_mark,
(max(mark)*100/sum(weight)) max_mark, mark
from AssignmentGroup
    natural full join RubricItem
    natural full join Grader
    natural full join Result
group by assignment_id, group_id, username, mark;
 
 
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
select assignment_id, username, 
	count(mark) AS num_marked,
	count(*) - count(mark) AS num_not_marked, 
	min(min_mark), max(max_mark)
from (select * from maxmin) as m
where username is not null
group by assignment_id, username
order by assignment_id, username;