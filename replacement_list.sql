/*
In this file, the data for Rough Replacement List has been queried from database,
the code is mainly written as PL/SQL for Oracle SQL Developer.
If using to retrieve data from Snowflake, there are some syntax errors may cause.

Output:
BID, TITLE, #ACTIVE, #INACTIVE, TOTAL # OF COPIES, TOTAL ALL TIME CIRCS, 
TOTAL CIRCS ON ACTIVE ITEMS, PUBLICATION, ISBN
*/

WITH replacement AS (
SELECT
i.bid, 
bm.title,
i.status AS "STATUS",
si.description AS "STATUS_Des",
CASE 
    WHEN si.description IN ('Checked out', 'Display', 'Hold Pending', 
    'Hold Shelf', 'In Process', 'In Transit', 'In Transit Hold', 
    'On Shelf', 'Overdue') THEN 'Active'
    WHEN si.description IN ('Damaged', 'Lost', 'Missing', 
    'Not On Shelf', 'Traced', 'Withdrawn') THEN 'Inactive'
    ELSE 'Unknown'
END AS statVal,
i.cumulativehistory AS cumulative, 
bm.publishingdate AS pubdate,  
bm.isbn
FROM item_v2 i 
LEFT JOIN BBIBMAP_V2 bm ON (i.BID = bm.BID AND i.INSTBIT = bm.INSTBIT AND bm.FOLDER = 0)
LEFT JOIN systemitemcodes_v2 si ON (si.code = i.status AND si.type = i.type)
LEFT JOIN media_v2 m ON i.media = m.mednumber
LEFT JOIN branch_v2 br ON br.branchnumber = i.owningbranch
GROUP BY i.bid, bm.title, br.branchcode, i.status, si.description, 
i.cumulativehistory, bm.publishingdate, bm.isbn
ORDER BY i.bid ASC
), 
replaceList AS (
SELECT bid, title, statVal, count(*) AS NumCopies, 
sum(cumulative) AS HistoryCircs, pubdate, isbn
FROM replacement 
WHERE statVal IN ('Active', 'Inactive')
GROUP BY bid, title, statVal, pubdate, isbn
ORDER BY bid
),
activeList AS (
SELECT bid, title, statVal AS Active, NumCopies AS ActiveCopies, 
HistoryCircs AS ActiveHistoryCircs, pubdate, isbn
FROM replaceList
WHERE statVal IN ('Active')
),
inactiveList AS (
SELECT bid, title, statVal AS Inactive, NumCopies AS InactiveCopies, HistoryCircs AS InactiveHistCircs
FROM replaceList
WHERE statVal IN ('Inactive')
),
totalList AS (
SELECT bid, title, count(*) AS AllCopies, sum(cumulative) AS AllCircs, pubdate, isbn
FROM replacement 
WHERE statVal IN ('Active', 'Inactive')
GROUP BY bid, title, pubdate, isbn
)
SELECT c.bid, c.title, 
a.ActiveCopies AS "#Active", 
b.InactiveCopies AS "#Inactive", 
c.AllCopies AS "Total # of Copies", 
c.AllCircs AS "Total All time Circs",
a.ActiveHistoryCircs AS "Total Circs on Active Items", 
b.InactiveHistCircs AS "Total Circs on Inactive Items", 
c.pubdate, c.isbn
FROM totalList c
JOIN activeList a ON a.bid = c.bid
JOIN inactiveList b ON b.bid = c.bid
WHERE a.ActiveCopies < 7
ORDER BY a.ActiveHistoryCircs, c.AllCircs ASC
