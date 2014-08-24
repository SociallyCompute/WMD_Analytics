update WMD_Three a, WMD_Three b
set a.creator = b.poster
where b.localID=-1
and a.qid = b.qid and a.forum=b.forum;

-- ** This identifies cases where the person is actually replying to a comment instead of the top of the thread.
SELECT a.uniqueID, a.poster, a.replyTo, a.creator, b.uniqueID, b.poster, b.replyTo, b.creator 
FROM WMD.WMD_Three a, WMD.WMD_Three b
where a.uniqueID = b.replyTo 
and a.replyTo is not NULL
and a.forum = b.forum
order by a.forum, a.qid;

update WMD.WMD_Three a, WMD.WMD_Three b
set a.creator = a.poster
where a.uniqueID = b.replyTo 
and a.replyTo is not NULL
and a.forum = b.forum
and a.uniqueID not like "%top"
and a.replyTo not like "%top";

update WMD.WMD_Three 
set creator = null 
where replyTo is null;

call weightme();

-- extraction
Select * from WMD_Three
order by forum, qid, localID, `date`;

