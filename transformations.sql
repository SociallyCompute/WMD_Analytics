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
-- This got dumped to the .json file then.



-- Below are mapping notes, that helped to conceptually work through how to 
-- apply the concepts from the Group Informatics Warehouse to this corpora
-- in a lighter weight manner (i.e., not having to break out a ton of dimension and 
-- fact oriented tables, etc. )

/*Events_Stage Field	WebMD	Notes
		
ID		
context_id	concat(forum, "_",qid)	**Added Column "forum" when merging separate DBs
Environment_code	WebMD	
context_name	WebMD	
context_type	Medical	
event_ip	"na"	
event_session	qid	
event_action	jforum.new	
event_object	generated	
event_url	"na"	
event_author_id	poster	
event_author_name	poster	
event_date	date	
object_creator	phpbb_posts.user_id (explosion)	**Added Column "Creator"
parent_id	phpbb_posts.forum_id	*/
