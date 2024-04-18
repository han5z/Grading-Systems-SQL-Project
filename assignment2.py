"""CSC343 Assignment 2

=== CSC343 Fall 2023 ===
Department of Computer Science,
University of Toronto

This code is provided solely for the personal and private use of
students taking the CSC343 course at the University of Toronto.
Copying for purposes other than this use is expressly prohibited.
All forms of distribution of this code, whether as given or with
any changes, are expressly prohibited.

Authors: Diane Horton and Marina Tawfik

All of the files in this directory and all subdirectories are:
Copyright (c) 2023

=== Module Description ===

This file contains the Markus class and some simple testing functions.
"""
import datetime as dt
import psycopg2 as pg
import psycopg2.extensions as pg_ext
import psycopg2.extras as pg_extras
from typing import Optional


class Markus:
    """A class that can work with data conforming to the schema in schema.ddl.

    === Instance Attributes ===
    connection: connection to a PostgreSQL database of Markus-related
        information.

    Representation invariants:
    - The database to which <connection> holds a reference conforms to the
      schema in schema.ddl.
    """
    connection: Optional[pg_ext.connection]

    def __init__(self) -> None:
        """Initialize this Markus instance, with no database connection
        yet.
        """
        self.connection = None

    def connect(self, dbname: str, username: str, password: str) -> bool:
        """Establish a connection to the database <dbname> using the
        username <username> and password <password>, and assign it to the
        instance attribute <connection>. In addition, set the search path
        to markus.

        Return True if the connection was made successfully, False otherwise.
        I.e., do NOT throw an error if making the connection fails.

        >>> a2 = Markus()
        >>> # The following example will only work if you change the dbname
        >>> # and password to your own credentials.
        >>> a2.connect("csc343h-marinat", "marinat", "")
        True
        >>> # In this example, the connection cannot be made.
        >>> a2.connect("invalid", "nonsense", "incorrect")
        False
        """
        try:
            self.connection = pg.connect(
                dbname=dbname, user=username, password=password,
                options="-c search_path=markus"
            )
            return True
        except pg.Error:
            return False

    def disconnect(self) -> bool:
        """Close this instance's connection to the database.

        Return True if closing the connection was successful, False otherwise.
        I.e., do NOT throw an error if closing the connection fails.

        >>> a2 = Markus()
        >>> # The following example will only work if you change the dbname
        >>> # and password to your own credentials.
        >>> a2.connect("csc343h-marinat", "marinat", "")
        True
        >>> a2.disconnect()
        True
        """
        try:
            if self.connection and not self.connection.closed:
                self.connection.close()
            return True
        except pg.Error:
            return False

    def get_groups_count(self, assignment: int) -> Optional[int]:
        """Return the number of groups defined for the assignment with
        ID <assignment>.

        Return None if the operation was unsuccessful i.e., do NOT throw
        an error.

        The operation is considered unsuccessful if <assignment> is an invalid
        assignment ID.

        Note: if <assignment> is a valid assignment ID but happens to have
        no groups defined, the operation is considered successful,
        with a returned count of 0.
        """


        try:
            # Open a cursor object
            cursor = self.connection.cursor()

            cursor.execute("""
                select * from Assignment
                where assignment_id = %s
                """, [assignment])
            row = cursor.fetchone()
            if row == None:
                return None

            cursor.execute("""
                            select count(group_id) 
                            from Assignment join AssignmentGroup
                            on Assignment.assignment_id = AssignmentGroup.assignment_id
                            where Assignment.assignment_id = %s 
                            """, [assignment])
            return cursor.fetchone()[0]
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return None
        finally:
            cursor.close()

    def assign_grader(self, group: int, grader: str) -> bool:
        """Assign grader <grader> to the assignment group <group>, by updating
        the Grader table appropriately.

        If <group> has already been assigned a grader, update the Result table
        to reflect that the new grader is <grader>.

        Return True if the operation is successful, and False Otherwise.
        I.e., do NOT throw an error. If the operation is unsuccessful, no
        changes should be made to the database.

        The operation is considered unsuccessful if one or more of the following
        is True:
            * <group> is not a valid group ID i.e., it doesn't exist in the
              AssignmentGroup table.
            * <grader> is an invalid Markus username or is neither a
              TA nor an instructor.

        Note: if <grader> is already assigned to the assignment group <group>,
        the operation is considered to be successful.
        """
        try:
            cursor = self.connection.cursor()

            # Check validity of input parameters
            # First check if group is a valid group ID
            cursor.execute("""
                            select * from AssignmentGroup
                            where group_id = %s""",
                            [group])
            if cursor.fetchone() == None:
                return False

            # Check if grader is a valid Markus username for a TA or instructor
            cursor.execute("""
                            select * from MarkusUser
                            where username = %s
                            and (type = 'instructor'
                                or type = 'TA')""",
                            [grader])
            if cursor.fetchone() == None:
                return False

            # Check if group has already been assigned a grader
            cursor.execute("""
                        select * from Grader
                        where group_id = %s""",
                        [group])
            row = cursor.fetchone()
            if row == None:
                cursor.execute("""
                                insert into Grader
                               values (%s, %s)""", [group, grader])
                return True
            else:
                cursor.execute("""
                               update Grader
                               set username = %s
                               where group_id = %s""",
                               [grader, group])
                return True
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return False
        finally:
            self.connection.commit()
            cursor.close()

    def remove_student(self, username: str, date: dt.date) -> int:
        """Remove the student identified by <username> from all groups on
        assignments that have due date greater than (i.e., after) <date>.

        Return the number of groups the user was removed from, or -1 if the
        operation was unsuccessful, i.e. do NOT throw an error.

        The operation is considered unsuccessful if <username> is an invalid
        user or is not a student. Note: if <username> is a valid student but
        is not a member of any group, the operation is considered successful,
        but no deletion will occur.

        Make sure to delete any empty group(s) that result(s) from deleting the
        target memberships of <username>.

        Note: Compare the due date of an assignment on the precision of days.
        E.g., if <date> is 2023-09-01, an assignment due on 2023-09-01 23:59
        is not considered to be "after" that because it is not due on a later
        day.
        """
        try:
            curr = self.connection.cursor()
            # Check if a username exists and is of type student
            curr.execute("""SELECT *
                         FROM MarkusUser 
                         WHERE MarkusUser.username = %s and MarkusUser.type = 'student'
                         """, (username, ))
            res = curr.fetchall()
            if not res:
                return -1
            # Find all group_id's that the studennt was a part of
            curr.execute("""SELECT group_id
                         FROM Membership
                         WHERE Membership.username = %s""", (username, ))
            groups = curr.fetchall()
            # No deletion occurs if the student is not part of any group
            if not groups:
                return 0
            
            ### Create views
            # -- Find all the assignments after due date specified
            curr.execute("""
                        CREATE VIEW DueDateAfterAssignments AS
                         select assignment_id
                         from Assignment
                         where date(due_date) > %s""", [date])
            # -- Groups of the given username
            curr.execute("""
                        CREATE VIEW UserAssignedGroups AS
                            SELECT group_id
                            FROM Membership
                            WHERE Membership.username = %s""", (username, ))
            # -- Assignments that the user was assigned to
            curr.execute("""
                        CREATE VIEW UserAssignedAssignments AS
                         SELECT AssignmentGroup.assignment_id, G.group_id 
                         FROM AssignmentGroup join
                                (select * from UserAssignedGroups) G
                                on G.group_id = AssignmentGroup.group_id""")
            
            # -- Get all the groups the user needs to be removed from
            curr.execute("""
                         CREATE VIEW DeleteGroups AS
                         SELECT MG.group_id
                         FROM (select * from UserAssignedAssignments) MG
                            join (SELECT * from DueDateAfterAssignments) A 
                            on A.assignment_id = MG.assignment_id""")
            
            # -- Find all solo groups that need to be removed from AssignmentGroup
            curr.execute("""
                        CREATE VIEW DeleteAssignmentGroups AS
                        select group_id
                        from Membership natural join 
                            (select * from DeleteGroups) R1
                        group by group_id
                        having count(username) = 1""")

            ### Execute method requirements
            # Number of groups the user was removed from
            curr.execute("""select * from DeleteGroups""")
            rowc = curr.rowcount

            # Delete the empty groups that result from deleting target memberships
            curr.execute("""DELETE
                        FROM AssignmentGroup
                        WHERE group_id IN (select * from DeleteAssignmentGroups)""")
            
            # Delete the user from the group they are assigned
            curr.execute("""DELETE 
                         FROM Membership
                         WHERE group_id IN (select * from DeleteGroups)
                         AND username = %s""", (username, ))
            return rowc
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return -1
        finally:
            # Delete views
            curr.execute("""DROP VIEW IF EXISTS DueDateAfterAssignments CASCADE""")
            curr.execute("""DROP VIEW IF EXISTS UserAssignedGroups CASCADE""")
            curr.execute("""DROP VIEW IF EXISTS UserAssignedAssignments CASCADE""")
            curr.execute("""DROP VIEW IF EXISTS DeleteGroups CASCADE""")
            curr.execute("""DROP VIEW IF EXISTS DeleteAssignmentGroups CASCADE""")
            self.connection.commit()
            curr.close()

    def create_groups(
        self, assignment_to_group: int, other_assignment: int, repo_prefix: str
    ) -> bool:
        """Create student groups for <assignment_to_group> based on their
        performance in <other_assignment>. The repository URL of all created
        groups will start with <repo_prefix>.

        Find all students who are defined in the Users table and put each of
        them into a group for <assignment_to_group>.
        Suppose there are n. Each group will be of the maximum size allowed for
        the assignment (call that k), except for possibly one group of smaller
        size if n is not divisible by k.

        Note: k may be as low as 1.

        The choice of which students to put together is based on their grades on
        <other_assignment>, as recorded in table Result. (It makes no difference
        whether the grades were released or not.)  Starting from the
        highest grade on <other_assignment>, the top k students go into one
        group, then the next k students go into the next, and so on. The last
        n % k students form a smaller group.

        Students with no grade recorded for <other_assignment> come at the
        bottom of the list, after students who received zero. When there is a
        tie for grade (or non-grade) on <other_assignment>, take students in
        order by username, using alphabetical order from A to Z.

        When a group is created, its group ID is generated automatically because
        the group_id attribute of table AssignmentGroup uses the next value in
        a SQL SEQUENCE. The value of a group's attribute repo is
            repoPrefix + "/group_" + group_id

        Return True if the operation is successful, and False Otherwise.
        I.e., do NOT throw an error. If the operation is unsuccessful, no
        changes should be made to the database.

        The operation is considered unsuccessful if one or more of the following
        is True:
            * There is no assignment with ID <assignment_to_group> or
              no assignment with ID <other_assignment>.
            * One or more group(s) have already been defined for
              <assignment_to_group>.

        Note: If there are no students in the db, define no groups for
        <assignment_to_group>) and return True; the operation is considered
        successful. No changes should be made to the db in this case.

        Precondition: The group_min for <assignment_to_group> is 1.
        """
        sql_check_assignment = """
        SELECT group_max FROM Assignment WHERE assignment_id = %s
        """

        sql_check_no_groups = """
        SELECT * FROM AssignmentGroup WHERE assignment_id = %s  LIMIT 1
        """
        try:
            curr = self.connection.cursor()
            curr.execute(sql_check_assignment, (assignment_to_group, ))
            group_max = curr.fetchone()
            if not group_max:
                return False
            group_max = group_max[0]
            curr.execute(sql_check_no_groups, (assignment_to_group, ))
            groups = curr.fetchall()
            if groups:
                return False
            curr.execute("""SELECT * FROM MarkusUser WHERE type = 'student'""")
            studs = curr.fetchall()
            if not studs:
                return True
            curr.execute("""SELECT max(group_id)
                         FROM AssignmentGroup""")
            max_id = curr.fetchone()[0]
            curr.execute("""SELECT username
                         FROM Result natural right join Membership
                         ORDER BY
                         CASE WHEN mark IS NULL THEN -1 ELSE mark END DESC, username
                         """)
            names = curr.fetchall()
            i = 1
            for item in names:
                name = item[0]
                if i == 1:
                    max_id += 1
                    rep = repo_prefix + "/group_" + str(max_id)
                    curr.execute("""INSERT INTO AssignmentGroup(assignment_id, repo)
                                 VALUES
                                    (%s, %s)
                                 """, (assignment_to_group, rep, ))
                curr.execute("""INSERT INTO Membership(username, group_id)
                             VALUES
                                (%s, %s)
                             """, (name, max_id, ))
                if i == group_max:
                    i = 1
                else:
                    i += 1
            self.connection.commit()
            return True
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return False
        finally:
            curr.close()


def setup(
    dbname: str, username: str, password: str, schema_path: str, data_path: str
) -> None:
    """Set up the testing environment for the database <dbname> using the
    username <username> and password <password> by importing the schema file
    at <schema_path> and the file containing the data at <data_path>.

    <schema_path> and <data_path> are the relative/absolute paths to the files
    containing the schema and the data respectively.
    """
    connection, cursor, schema_file, data_file = None, None, None, None
    try:
        connection = pg.connect(
            dbname=dbname, user=username, password=password,
            options="-c search_path=markus"
        )
        cursor = connection.cursor()

        schema_file = open(schema_path, "r")
        cursor.execute(schema_file.read())

        data_file = open(data_path, "r")
        cursor.execute(data_file.read())

        connection.commit()
    except Exception as ex:
        connection.rollback()
        raise Exception(f"Couldn't set up environment for tests: \n{ex}")
    finally:
        if cursor and not cursor.closed:
            cursor.close()
        if connection and not connection.closed:
            connection.close()
        if schema_file:
            schema_file.close()
        if data_file:
            data_file.close()


def test_get_groups_count() -> None:
    """Test method get_groups_count.
    """
    # TODO: Change the values of the following variables to connect to your
    #  own database:
    dbname = "csc343h-jiahanse"
    user = "jiahanse"
    password = ""

    # The following uses the relative paths to the schema file and the data file
    # we have provided. For your own tests, you will want to make your own data
    # files to use for testing.
    schema_file = "/h/u9/c1/01/jiahanse/csc343db/a2/schema.ddl"
    data_file = "/h/u9/c1/01/jiahanse/csc343db/a2/starterdata.sql"

    a2 = Markus()
    try:
        connected = a2.connect(dbname, user, password)

        # The following is an assert statement. It checks that the value for
        # connected is True. The message after the comma will be printed if
        # that is not the case (that is, if connected is False).
        # Use the same notation throughout your testing.
        assert connected, f"[Connect] Expected True | Got {connected}."

        # The following function call will set up the testing environment by
        # loading a fresh copy of the schema and the sample data we have
        # provided into your database. You can create more sample data files
        # and call the same function to load them into your database.
        setup(dbname, user, password, schema_file, data_file)

        # TODO: Test more methods here, or better yet, make more testing
        # functions, with each testing a different method, and call them from
        # the main block below.

        # ---------------------- Testing get_groups_count ---------------------#

        # Invalid assignment ID
        num = a2.get_groups_count(0)
        assert num is None, f"[Get Group Count] Expected: None. Got {num}."

        # Valid assignment ID. No groups recorded.
        num = a2.get_groups_count(3)
        assert num == 0, f"[Get Group Count] Expected: 0. Got {num}."

        # Valid assignment ID. Some groups recorded.
        num = a2.get_groups_count(2)
        assert num == 3, f"[Get Group Count] Expected: 3. Got {num}."

    finally:
        a2.disconnect()


def test_assign_grader() -> None:
    """Test method get_groups_count.
    """
    # TODO: Change the values of the following variables to connect to your
    #  own database:
    dbname = "csc343h-jiahanse"
    user = "jiahanse"
    password = ""

    # The following uses the relative paths to the schema file and the data file
    # we have provided. For your own tests, you will want to make your own data
    # files to use for testing.
    schema_file = "/h/u9/c1/01/jiahanse/csc343db/a2/schema.ddl"
    data_file = "/h/u9/c1/01/jiahanse/csc343db/a2/starterdata.sql"

    a2 = Markus()
    try:
        connected = a2.connect(dbname, user, password)
        assert connected, f"[Connect] Expected True | Got {connected}."

        setup(dbname, user, password, schema_file, data_file)

        # ---------------------- Testing assign_grader ------------------------#
        # Invalid grader username
        a_result = a2.assign_grader(2, 'skywalker')
        assert a_result is False, f"[Assign Grader] Expected: False. Got {a_result}."

        # Invalid group_id
        a_result = a2.assign_grader(11, 'dumbledore')
        assert a_result is False, f"[Assign Grader] Expected: False. Got {a_result}."

        # Valid inputs, new TA grader assigned
        a_result = a2.assign_grader(6, 'snapes')
        assert a_result is True, f"[Assign Grader] Expected: True. Got {a_result}."

        # Valid inputs, new instructor grader assigned
        a_result = a2.assign_grader(7, 'dumbledore')
        assert a_result is True, f"[Assign Grader] Expected: True. Got {a_result}."

        # Valid inputs, updating grader for existing row
        a_result = a2.assign_grader(3, 'lupinr4')
        assert a_result is True, f"[Assign Grader] Expected: True. Got {a_result}."

    finally:
        a2.disconnect()

def test_remove_student() -> None:
    """Test method get_groups_count.
    """
    # TODO: Change the values of the following variables to connect to your
    #  own database:
    dbname = "csc343h-jiahanse"
    user = "jiahanse"
    password = ""

    # The following uses the relative paths to the schema file and the data file
    # we have provided. For your own tests, you will want to make your own data
    # files to use for testing.
    schema_file = "/h/u9/c1/01/jiahanse/csc343db/a2/schema.ddl"
    data_file = "/h/u9/c1/01/jiahanse/csc343db/a2/starterdata.sql"

    a2 = Markus()
    try:
        connected = a2.connect(dbname, user, password)
        assert connected, f"[Connect] Expected True | Got {connected}."

        setup(dbname, user, password, schema_file, data_file)

        # -----------------------Testing remove_student -----------------------#
        # Valid inputs, two solo groups removed
        # remove_result = a2.remove_student('lovegoodl4', dt.date(2023, 10, 1))
        # assert remove_result == 2, f"[Remove Student] Expected: 2, Got {remove_result}."

        # Valid input, one membership removed from a multi group
        remove_result = a2.remove_student('weaslyr30', dt.date(2023, 10, 2))
        assert remove_result == 1, f"[Remove Student] Expected: 1, Got {remove_result}."

        # Valid inputs, 1 group removed due to assignment date
        remove_result = a2.remove_student('lovegoodl4', '2023-10-10')
        assert remove_result == 1, f"[Remove Student] Expected: 1, Got {remove_result}."

        # Invalid inputs, username does not exist
        remove_result = a2.remove_student('hmmmm', dt.date(2023, 10, 2))
        assert remove_result == -1, f"[Remove Student] Expected: -1, Got {remove_result}."

        # Invalid inputs, user is not a student
        remove_result = a2.remove_student('Dumbledore', dt.date(2023, 10, 2))
        assert remove_result == -1, f"[Remove Student] Expected: -1, Got {remove_result}."

    finally:
        a2.disconnect()

if __name__ == "__main__":
    # Un comment-out the next two lines if you would like to run the doctest
    # examples (see ">>>" in the methods connect and disconnect)
    # import doctest
    # doctest.testmod()

    test_get_groups_count()
    test_assign_grader()
    test_remove_student()
