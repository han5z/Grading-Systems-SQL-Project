-- Steady work.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6 (
	group_id integer NOT NULL,
	first_file varchar(25) DEFAULT NULL,
	first_time timestamp DEFAULT NULL,
	first_submitter varchar(25) DEFAULT NULL,
	last_file varchar(25) DEFAULT NULL,
	last_time timestamp DEFAULT NULL,
	last_submitter varchar(25) DEFAULT NULL,
	elapsed_time interval DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS a1_submissions CASCADE;
DROP VIEW IF EXISTS first_submission CASCADE;
DROP VIEW IF EXISTS last_submission CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW a1_submissions AS
select group_id, username, file_name, submission_date
from AssignmentGroup natural full join Submissions natural full join Assignment
where description = 'A1';

CREATE VIEW first_submission AS
select group_id, file_name as first_file, submission_date as first_time,
        username as first_submitter
from (select * from a1_submissions) a1
where submission_date <= ALL
    (select submission_date
    from (select * from a1_submissions) a2
    where a1.group_id = a2.group_id);

CREATE VIEW last_submission AS
select group_id, file_name as last_file, submission_date as last_time,
        username as last_submitter
from (select * from a1_submissions) a1
where submission_date >= ALL
    (select submission_date
    from (select * from a1_submissions) a2
    where a1.group_id = a2.group_id);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
select group_id, first_file, first_time, first_submitter,
        last_file, last_time, last_submitter,
        (last_time - first_time) AS elapsed_time
from (select * from first_submission) f
    natural join
    (select * from last_submission) l;