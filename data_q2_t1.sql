SET SEARCH_PATH TO markus;


INSERT INTO 
	MarkusUser(username, surname, firstname, type) 
VALUES
	('alice1', 'alic', 'aliali', 'student'),
	('bob', 'jones', 'bobby', 'student'),
    ('student', 'solo', 'solsol', 'student'),
    ('student1', 'stud', 'stustu', 'student'),
    ('student2', 'stud', 'stustu', 'student'),
    ('student3', 'stud', 'stustu', 'student'),
    ('student4', 'stud', 'stustu', 'student'),
    ('student5', 'stud', 'stustu', 'student'),
    ('student6', 'stud', 'stustu', 'student'),
    ('student7', 'stud', 'stustu', 'student'),
    ('student8', 'stud', 'stustu', 'student'),
    ('student9', 'stud', 'stustu', 'student'),
    ('student10', 'stud', 'stustu', 'student'),
    ('student11', 'stud', 'stustu', 'student'),
    ('t1myta', 't1my', 't1mt1m', 'TA'),
    ('t2someone', 't2so', 't2st2s', 'TA'),
    ('t4someone', 't4so', 't4st4s', 'TA');


INSERT INTO 
	Assignment(assignment_id, description, due_date, group_min, group_max)
VALUES
	(1, 'A1', '2023-10-01 11:00', 1, 3),
	(2, 'A2', '2023-10-02 11:00', 1, 4);


INSERT INTO 
	AssignmentGroup(assignment_id, repo) 
VALUES
	-- A1 - 11 groups
	(1, 'git+group_1_1'), -- group 1
	(1, 'git+group_2_1'), -- group 2
	(1, 'git+group_3_1'), -- group 3
	(1, 'git+group_4_1'), -- group 4
	(1, 'git+group_5_1'),
	(1, 'git+group_6_1'),
	(1, 'git+group_7_1'),
	(1, 'git+group_8_1'),
	(1, 'git+group_9_1'),
	(1, 'git+group_10_1'),
	(1, 'git+group_11_1'),
	-- A2 - 11 groups
	(2, 'git+group_11_2'),
	(2, 'git+group_12_2'),
	(2, 'git+group_13_2'),
	(2, 'git+group_14_2'),
	(2, 'git+group_15_2'),
	(2, 'git+group_16_2'),
	(2, 'git+group_17_2'),
	(2, 'git+group_18_2'),
	(2, 'git+group_19_2'),
	(2, 'git+group_20_2'),
	(2, 'git+group_21_2');
	 

INSERT INTO 
	Membership(username, group_id)
VALUES
    -- A1 groups
	('alice1', 1), -- 2 person group
	('student', 1),
	('student1', 2),
	('student2', 3),
	('student3', 4),
	('student4', 5),
	('student5', 6),
	('student6', 7),
	('student7', 8), -- 3 person group
	('student8', 8),
	('student9', 8),
	('student10', 9),
	('student11', 10),
	('bob', 11),
	-- A2 groups
	('student1', 12),
	('alice1', 13), -- 3 person group
	('student', 13),
	('student2', 13),
	('student4', 14),
	('student5', 15),
	('student6', 16),
	('student7', 17),
	('student8', 18),
	('student9', 19),
	('student10', 20),
	('student11', 21),
	('student3', 22);


INSERT INTO
	Submissions(submission_id, file_name, username, group_id, submission_date)
VALUES
	-- A1
	(1, 'a1.txt', 'alice1', 1, '2023-10-01 9:00'),
	(2, 'a1.txt', 'student1', 2, '2023-10-01 9:00'),
	(3, 'a1.txt', 'student2', 3, '2023-10-01 9:00'),
	(4, 'a1.txt', 'student3', 4, '2023-10-01 9:00'),
	(5, 'a1.txt', 'student4', 5, '2023-10-01 9:00'),
	(6, 'a1.txt', 'student5', 6, '2023-10-01 9:00'),
	(7, 'a1.txt', 'student6', 7, '2023-10-01 9:00'),
	(8, 'a1.txt', 'student8', 8, '2023-10-01 9:00'),
	(9, 'a1.txt', 'student10', 9, '2023-10-01 9:00'),
	(10, 'a1.txt', 'student11', 10, '2023-10-01 9:00'),
	(11, 'a1.txt', 'bob', 11, '2023-10-01 9:00'),

	-- A2
	(12, 'a2.txt', 'student1', 12, '2023-10-02 9:00'),
	(13, 'a2.txt', 'alice1', 13, '2023-10-02 9:00'),
	(14, 'a2.txt', 'student4', 14, '2023-10-02 9:00'),
	(15, 'a2.txt', 'student5',  15, '2023-10-02 9:00'),
	(16, 'a2.txt', 'student6',  16, '2023-10-02 9:00'),
	(17, 'a2.txt', 'student7',  17, '2023-10-02 9:00'),
	(18, 'a2.txt', 'student8',  18, '2023-10-02 9:00'),
	(19, 'a2.txt', 'student9',  19, '2023-10-02 9:00'),
	(20, 'a2.txt', 'student10',  20, '2023-10-02 9:00'),
	(21, 'a2.txt', 'student11',  21, '2023-10-02 9:00'),
	(22, 'a2.txt', 'student3',  22, '2023-10-02 9:00');



INSERT INTO 
	Grader(group_id, username)
VALUES
    -- A1
	(1, 't1myta'),
	(2, 't1myta'),
	(3, 't1myta'),
	(4, 't1myta'),
	(5, 't1myta'),
    (6, 't1myta'),
    (7, 't1myta'),
    (8, 't1myta'),
    (9, 't1myta'),
    (10, 't1myta'),
    (11, 't2someone'),
    (12, 't1myta'),
    (13, 't1myta'),
    (14, 't1myta'),
    (15, 't1myta'),
    (16, 't1myta'),
    (17, 't1myta'),
    (18, 't1myta'),
    (19, 't1myta'),
    (20, 't1myta'),
    (21, 't1myta'),
    (22, 't2someone');


INSERT INTO
	RubricItem(rubric_id, assignment_id, name, out_of, weight)
VALUES
	(1, 1, 'Criteria 1', 100, 100.0),
    (2, 2, 'Criteria 2', 100, 100.0);


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
	(9, 2, 76),
	(10, 2, 74),
	(11, 2, 77),
	(13, 2, 65);

INSERT INTO
	Result(group_id, mark, released)
VALUES
	(1, 45, true),
	(2, 55, true),
	(3, 49, true),
	(4, 72, true),
    (5, 31, False),
    (6, 40, True),
    (7, 50, False),
	(8, 10, False),
    (9, 76, True),
    (10, 74, False),
	(11, 33, False),
	(12, 85, False),
	(13, 39, True),
	(14, 65, False),
	(15, 81, False),
	(16, 78, False),
	(17, 72, False),
	(18, 67, False),
	(19, 69, False),
	(20, 83, False),
	(21, 27, False),
	(22, 70, False);
	



