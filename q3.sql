-- Solo superior.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
	assignment_id integer NOT NULL,
	description varchar(100) NOT NULL,
	num_solo integer NOT NULL,
	average_solo real NOT NULL,
	num_collaborators integer NOT NULL,
	average_collaborators real NOT NULL,
	average_students_per_group real NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS completed_grading CASCADE;
DROP VIEW IF EXISTS solo_or_multi CASCADE;
DROP VIEW IF EXISTS percentage_grades CASCADE;
DROP VIEW IF EXISTS stats_solo CASCADE;
DROP VIEW IF EXISTS stats_multi CASCADE;
DROP VIEW IF EXISTS students_per_group CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW completed_grading AS
select assignment_id
from AssignmentGroup natural full join Result
group by assignment_id
having count(assignment_id) = count(mark);

CREATE VIEW solo_or_multi AS
select assignment_id, group_id,
        CASE WHEN count(username) = 1 THEN count(username)
             WHEN count(username) > 1 THEN count(username)
        END AS member_count
from AssignmentGroup natural join Membership
group by assignment_id, group_id;

CREATE VIEW percentage_grades AS
select assignment_id, group_id, member_count,
        max(mark)*100/sum(weight) percentage
from (select * from solo_or_multi) s
        natural full join RubricItem
        natural full join Result
group by assignment_id, group_id, member_count;

CREATE VIEW stats_solo AS
select assignment_id,
        sum(member_count) num_solo,
        avg(percentage) average_solo
from (select * from percentage_grades) p
where member_count = 1
group by assignment_id;

CREATE VIEW stats_multi AS
select assignment_id,
        sum(member_count) num_collaborators,
        avg(percentage) average_collaborators
from (select * from percentage_grades) p
where member_count > 1
group by assignment_id;

CREATE VIEW students_per_group AS
select assignment_id, avg(member_count) average_students_per_group
from (select * from solo_or_multi) s
group by assignment_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
select assignment_id, description, num_solo, average_solo,
        num_collaborators, average_collaborators, average_students_per_group
from (select * from stats_solo) s1
    natural join (select * from stats_multi) s2
    natural join (select * from completed_grading) c
    natural join Assignment
    natural join students_per_group
where average_solo > average_collaborators;


