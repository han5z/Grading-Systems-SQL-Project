-- Getting soft?

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
	grader_username varchar(25) NOT NULL,
	grader_name varchar(100) NOT NULL,
	average_mark_all_assignments real NOT NULL,
	mark_change_first_last real NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS at_least_one CASCADE;
DROP VIEW IF EXISTS completed_at_least_ten CASCADE;
DROP VIEW IF EXISTS grader_with_avgmarks CASCADE;
DROP VIEW IF EXISTS average_increasing CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW at_least_one AS
SELECT username
FROM Assignment natural full join AssignmentGroup
    natural full join Grader
GROUP BY username
HAVING username is not null AND
    count(distinct assignment_id) = (SELECT COUNT(assignment_id)
            FROM Assignment);

CREATE VIEW completed_at_least_ten AS
SELECT DISTINCT username
FROM (SELECT username, assignment_id
        FROM Assignment natural full join AssignmentGroup
            natural full join Grader
            natural full join Result
        GROUP BY username, assignment_id
        HAVING count(mark) >= 10) Counting;

CREATE VIEW grader_with_avgmarks AS
select assignment_id, due_date, Grader.username, avg(mark) average
from Assignment natural full join AssignmentGroup
    natural full join Membership
    full join Grader on AssignmentGroup.group_id = Grader.group_id
    full join Result on Grader.group_id = Result.group_id
group by assignment_id, due_date, Grader.username
order by Grader.username, avg(mark);

CREATE VIEW average_increasing AS
select distinct username
from (select * from grader_with_avgmarks) c1
where not exists (
        select *
        from (select * from grader_with_avgmarks) c2
        where c1.username = c2.username
            and c1.assignment_id != c2.assignment_id
            and c2.due_date > c1.due_date
            and c2.average <= c1.average)
      and not exists (
        select *
        from (select * from grader_with_avgmarks) c3
        where c1.username = c3.username
            and c1.assignment_id != c3.assignment_id
            and c3.due_date < c1.due_date
            and c3.average > c1.average);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select username as grader_username,
        firstname || ' ' || surname as grader_name,
        avg(average) average_mark_all_assignments,
        (max(average) - min(average)) mark_change_first_last
from (select * from at_least_one) c1
    natural join
    (select * from completed_at_least_ten) c2
    natural join
    (select * from average_increasing) c3
    natural join
    (select username, average from grader_with_avgmarks) c4
    natural join MarkusUser
group by grader_username, grader_name;
