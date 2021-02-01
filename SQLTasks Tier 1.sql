/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
--------------------------------------------------------------------------------------------------------------------------------
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

A1: 

SELECT * 
FROM Facilities
WHERE membercost = 0.0

--------------------------------------------------------------------------------------------------------------------------------
/* Q2: How many facilities do not charge a fee to members? */

A2:

SELECT COUNT(facid)
FROM Facilities
WHERE membercost > 0;

--------------------------------------------------------------------------------------------------------------------------------
/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

A3: 

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0
AND membercost < (monthlymaintenance * .20);

--------------------------------------------------------------------------------------------------------------------------------

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

A4:

SELECT *
FROM Facilities
WHERE facid IN (1, 5);

--------------------------------------------------------------------------------------------------------------------------------
/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

A5:

SELECT name, monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	WHEN monthlymaintenance < 100 THEN 'cheap' END AS 'cheap/expensive'
FROM Facilities;
--------------------------------------------------------------------------------------------------------------------------------
/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

A6:

SELECT MAX(joindate)
FROM Members;

--------------------------------------------------------------------------------------------------------------------------------
/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

A7:

SELECT DISTINCT CONCAT(m.firstname, ' ', m.surname) AS name, f.name AS facility
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f on f.facid = b.facid 
WHERE b.facid IN (0,1)
ORDER BY name;


--------------------------------------------------------------------------------------------------------------------------------
/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

A8:

SELECT f.name as facility, 
	CONCAT(m.firstname, ' ', m.surname) AS member_name, 
    CASE WHEN m.firstname = 'GUEST' THEN (f.guestcost * b.slots) ELSE (f.membercost * b.slots) END AS cost

FROM Bookings as b

INNER JOIN Facilities as f
ON b.facid = f.facid

INNER JOIN Members as m
ON b.memid = m.memid

WHERE b.starttime >= '2012-09-04' AND starttime < '2012-09-15'
AND (CASE WHEN m.firstname = 'GUEST' THEN f.guestcost * b.slots ELSE f.membercost * b.slots END) > 30

ORDER BY cost DESC;



--------------------------------------------------------------------------------------------------------------------------------
/* Q9: This time, produce the same result as in Q8, but using a subquery. */


A9:

SELECT
    name as facility,
    CONCAT(firstname, ' ', surname) AS member_name,
    cost

FROM(
    SELECT
        m.firstname,
        m.surname,
        b.facid,
        f.name,
        CASE WHEN m.firstname = 'GUEST' THEN (f.guestcost * b.slots) 
        ELSE (f.membercost * b.slots) END AS cost
    
    FROM Bookings as b
    
    INNER JOIN Facilities as f
    ON b.facid = f.facid
    
    INNER JOIN Members as m
    ON b.memid = m.memid
    
    WHERE b.starttime >= '2012-09-04' AND starttime < '2012-09-15') AS subquery
    
WHERE cost > 30
ORDER BY cost DESC;
   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 --------------------------------------------------------------------------------------------------------------------------------
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

A10:

SELECT
    facility_name, 
    SUM(revenue) as total_revenue
    
FROM(
    SELECT b.bookid,
    f.facid, 
    f.name as facility_name, 
    m.surname, 
    f.membercost, 
    f.guestcost, 
    b.slots,
    CASE WHEN m.surname = 'GUEST' THEN (f.guestcost * b.slots)
    ELSE (f.membercost * b.slots) END AS revenue
    
    FROM Facilities as f
    
    INNER JOIN Bookings as b
    ON f.facid = b.facid
    
    INNER JOIN Members as m
    ON b.memid = m.memid) AS subquery

GROUP BY facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue ASC;

--------------------------------------------------------------------------------------------------------------------------------

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

A11:

SELECT 
    m1.memid AS member_id, 
    (m1.surname || ',' || ' ' || m1.firstname) as member_name, 
    m1.recommendedby AS recommended_by_id, 
    (m2.surname || ',' || ' ' || m2.firstname) AS recommending_member_name

FROM Members as m1

INNER JOIN Members as m2
ON m1.recommendedby = m2.memid

WHERE m1.recommendedby > 0
ORDER BY m1.surname, m1.firstname;


NOTES: CONCAT() not suppported by SQLite, used || instead.
--------------------------------------------------------------------------------------------------------------------------------

/* Q12: Find the facilities with their usage by member, but not guests */

A12:

SELECT 
    facid,
    name as facility_name,
    COUNT(bookid) AS number_of_bookings

FROM(
    SELECT 
        f.facid,
        f.name,
        b.bookid,
        b.memid
        
    FROM Bookings as b
    
    INNER JOIN Facilities as f
    ON b.facid = f.facid
    
    WHERE b.memid > 0) AS subquery


GROUP BY facility_name
ORDER BY number_of_bookings DESC;


NOTES: 'Usage' interpretted as one instance of a booking by a member.
--------------------------------------------------------------------------------------------------------------------------------

/* Q13: Find the facilities usage by month, but not guests */


SELECT 
    month,
    facid,
    name as facility_name,
    COUNT(bookid) AS number_of_bookings

FROM(
    SELECT 
        f.facid,
        f.name,
        b.bookid,
        b.memid,
        strftime('%m', b.starttime) AS month
        
    FROM Bookings as b
    
    INNER JOIN Facilities as f
    ON b.facid = f.facid
    
    WHERE b.memid > 0) AS subquery

GROUP BY month, facid;


NOTES: EXTRACT(MONTH FROM b.starttime) is not supported by SQLite, instead used strftime('%m', b.starttime) to extract the month. 
