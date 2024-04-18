SET SEARCH_PATH TO markus;


INSERT INTO 
	MarkusUser(username, surname, firstname, type) 
VALUES
	('another', 'anot', 'anoano', 'student'),
    ('solostudent', 'solo', 'solsol', 'student'),
    ('sombody', 'some', 'somsom', 'student'),
    ('someoneelse', 'some', 'somsom', 'student'),
    ('studentname', 'stud', 'stustu', 'student'),
    ('t5someone', 't5so', 't5st5s', 'TA');


INSERT INTO 
	Assignment(assignment_id, description, due_date, group_min, group_max)
VALUES
	(1, 'A1', '2023-10-01 11:00', 1, 1);


INSERT INTO 
	AssignmentGroup(assignment_id, repo) 
VALUES
	-- A1
	(1, 'git+group_1_1'), -- group 1
	(1, 'git+group_2_1'), -- group 2
	(1, 'git+group_3_1'), -- group 3
	(1, 'git+group_4_1'), -- group 4
	(1, 'git+group_5_1'); -- group 5
	 

INSERT INTO 
	Membership(username, group_id)
VALUES
	('another', 3),
    ('solostudent', 1),
    ('sombody', 4),
    ('someoneelse', 2),
    ('studentname', 5);


INSERT INTO
	Submissions(submission_id, file_name, username, group_id, submission_date)
VALUES
	-- A1
	(1, 'a1.txt', 'solostudent', 1, '2023-10-01 9:00'),
	(2, 'a1.txt', 'someoneelse', 2, '2023-10-01 9:00'),
	(3, 'a1.txt', 'another', 3, '2023-10-01 9:00'),
	(4, 'a1.txt', 'somebody', 4, '2023-10-01 9:00'),
	(5, 'a1.txt', 'studentname', 5, '2023-10-01 9:00');


INSERT INTO 
	Grader(group_id, username)
VALUES
	(1, 't5someone'),
	(2, 't5someone'),
	(3, 't5someone'),
	(4, 't5someone'),
	(5, 't5someone');


INSERT INTO
	RubricItem(rubric_id, assignment_id, name, out_of, weight)
VALUES
	(1, 1, 'Criteria 1', 100, 100.0);


INSERT INTO 
	Grade(group_id, rubric_id, grade)
VALUES
	-- A1
	(1, 1, 90),
	(2, 1, 21),
	(3, 1, 55),
	(4, 1, 84),
	(5, 1, 32);
	



