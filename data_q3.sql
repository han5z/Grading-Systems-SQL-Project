SET SEARCH_PATH TO markus;


INSERT INTO 
	MarkusUser(username, surname, firstname, type) 
VALUES
	('alice1', 'alic', 'aliali', 'student'),
    ('solostudent', 'solo', 'solsol', 'student'),
    ('someoneelse', 'some', 'somsom', 'student'),
    ('student1', 'stud', 'stustu', 'student'),
    ('student2', 'stud', 'stustu', 'student'),
    ('student3', 'stud', 'stustu', 'student'),
    ('t1myta', 't1my', 't1mt1m', 'TA'),
    ('t2someone', 't2so', 't2st2s', 'TA'),
    ('t4someone', 't4so', 't4st4s', 'TA');


INSERT INTO 
	Assignment(assignment_id, description, due_date, group_min, group_max)
VALUES
	(1, 'A1', '2023-10-01 11:00', 1, 1),
	(2, 'A2', '2023-10-02 11:00', 1, 3),
	(3, 'A3', '2023-10-03 11:00', 1, 2);


INSERT INTO 
	AssignmentGroup(assignment_id, repo) 
VALUES
	-- A1
	(1, 'git+group_1_1'), -- group 1
	(1, 'git+group_2_1'), -- group 2
	(1, 'git+group_3_1'), -- group 3
	(1, 'git+group_4_1'), -- group 4

	-- A2
	(2, 'git+group_5_2'), -- group 5
	(2, 'git+group_6_2'), -- group 6
	(2, 'git+group_7_2'), -- group 7
	(2, 'git+group_8_2'), -- group 8

	-- A3
    (3, 'git+group_9_3'), -- group 9
    (3, 'git+group_10_3'), -- group 10
    (3, 'git_group_11_3'), -- group 11
    (3, 'git_group_12_3'), -- group 12
    (3, 'git_group_13_3'); -- group 13
	 

INSERT INTO 
	Membership(username, group_id)
VALUES
	('alice1', 4),
    ('alice1', 6),
    ('alice1', 11), -- group 11
    ('solostudent', 1),
    ('solostudent', 13),
    ('someoneelse', 2),
    ('someoneelse', 5),
    ('someoneelse', 11), -- group 11
    ('student1', 3), -- group 3
    ('student1', 7),
    ('student1', 9),
    ('student2', 3), -- group 3
    ('student2', 8),
    ('student2', 10),
    ('student3', 12);


INSERT INTO
	Submissions(submission_id, file_name, username, group_id, submission_date)
VALUES
	-- A1
	(1, 'a1.txt', 'solostudent', 1, '2023-10-01 9:00'),
	(2, 'a1.txt', 'someoneelse', 2, '2023-10-01 9:00'),
	(3, 'a1.txt', 'student1', 3, '2023-10-01 9:00'),
	(4, 'a1.txt', 'alice1', 4, '2023-10-01 9:00'),
	-- A2
	(5, 'a2.txt', 'someoneelse', 5, '2023-10-01 9:00'),
	(6, 'a2.txt', 'alice1', 6, '2023-10-01 9:00'),
	(7, 'a2.txt', 'student1', 7, '2023-10-01 9:00'),
	(8, 'a2.txt', 'student2',  8, '2023-10-01 9:00'),
	-- A3
	(9, 'a3.txt', 'student1', 9, '2023-10-01 9:00'),
	(10, 'a3.txt', 'student2', 10, '2023-10-02 9:00'),
    (11, 'a3.txt', 'alice1', 11, '2023-10-02 9:00'),
    (12, 'a3.txt', 'student3', 12, '2023-10-02 9:00'),
    (13, 'a3.txt', 'solostudent', 13, '2023-10-02 9:00');


INSERT INTO 
	Grader(group_id, username)
VALUES
	(1, 't1myta'),
	(2, 't4someone'),
	(3, 't1myta'),
	(4, 't2someone'),
	(5, 't1myta'),
    (6, 't4someone'),
    (7, 't4someone'),
    (8, 't2someone'),
    (9, 't1myta'),
    (10, 't4someone'),
    (11, 't2someone'),
    (12, 't2someone'),
    (13, 't2someone');


INSERT INTO
	RubricItem(rubric_id, assignment_id, name, out_of, weight)
VALUES
	(1, 1, 'Criteria 1', 100, 100.0),
    (2, 2, 'Criteria 2', 100, 100.0),
    (3, 3, 'Criteria 3', 100, 100.0);


INSERT INTO 
	Grade(group_id, rubric_id, grade)
VALUES
	-- A1
	(1, 1, 45),
	(3, 1, 49),
	(4, 1, 72),
	(5, 2, 31),
	(6, 2, 40),
	(7, 2, 50),
	(9, 3, 76),
	(10, 3, 74),
	(11, 3, 77),
	(13, 3, 65);

INSERT INTO
	Result(group_id, mark, released)
VALUES
	-- A1
	(1, 45, true),
	(3, 49, true), -- 2 members
	(4, 72, true),
	-- A2
    (5, 31, False),
    (6, 40, True),
    (7, 50, False),
    (8, 56, True),
	-- A3
    (9, 76, True),
    (10, 74, False),
    (11, 74, False), -- 2 members
    (12, 74, False),
    (13, 74, False);
	



