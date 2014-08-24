DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `weightme`()
BEGIN
-- Variable declaration
/*DECLARE p_event_url varchar(300);
DECLARE p_last_url varchar(300);
DECLARE p_event_date datetime;
DECLARE p_last_date datetime;
declare first_date datetime;
DECLARE p_event_author_id varchar(32);
DECLARE p_new_object_creator varchar(32);
DECLARE no_more_rows BOOLEAN;
DECLARE p_id integer;
declare event_action_create varchar(32);
declare event_action_read varchar(32);*/

declare p_uniqueID varchar(25);
declare p_qid varchar(45);
declare p_title varchar(20000);
declare p_poster varchar(50);
declare p_date datetime;
declare p_replyTo varchar(25);
declare p_content varchar(20000);
declare p_forum varchar(45);
declare p_creator varchar(45);
declare p_row_type varchar(45);
declare p_weight_in_minutes numeric(11,2);

DECLARE no_more_rows BOOLEAN;

declare p_last_forum varchar(45);
declare p_last_qid varchar(45);

declare p_last_date datetime;
declare p_first_date datetime;
declare i int;

-- Here is the declaration of the cursor
/*DECLARE myCurse CURSOR FOR SELECT id, event_url, event_author_id, event_date
 FROM cans_warehouse.events_stage WHERE event_action='jforum.new' ORDER BY event_url,event_date ASC;*/
DECLARE myCurse CURSOR FOR SELECT uniqueID, qid, title, poster, `date`, replyTo, content, forum, creator
from WMD_Three order by forum, qid, `date` ASC;

DECLARE CONTINUE HANDLER FOR NOT FOUND
               SET no_more_rows = TRUE;

-- cursor is opened and looped through
/*OPEN myCurse;
loop_myCurse:  LOOP
   FETCH myCurse
   INTO p_id,
	   p_event_url,
       p_event_author_id,
       p_event_date;
IF no_more_rows THEN
       CLOSE myCurse;
       LEAVE loop_myCurse;
END IF;*/

-- opening and looping the cursor
OPEN myCurse;
loop_myCurse: LOOP
  fetch myCurse
    into p_uniqueID, p_qid, p_title, p_poster, p_date, p_replyTo, p_content, p_forum, p_creator;
  IF no_more_rows THEN
       CLOSE myCurse;
       LEAVE loop_myCurse;
  END IF;


/* Here the logic is somewhat simplified over the gim_warehouse example.  Fundamentally, 
we are saying that we will sort through the forums in order of the forum (ADHD, etc) and the "qid",
which is a unique ID for each thread.  We will:

1) calculate the time distance between each post and each prior post
2) Insert new rows for each post that define implicit read information for each response at the overall thread level
3) Calculate time distances for specific response pairs within the thread; this is distinct from some prior work with
a completely flat response structure.  In this response network, there is some default capacity (which is mostly what people use)
to just respond at the thread level ... however, there also exists a capacity to respond to people who resond at 
the thread level in WEBMD ... creating a more specific type of response; arguable a stronger and more direct one between
individuals than the response at the thread level ... probably worth considering as a factor in weighting 
*/

IF (p_last_forum != p_forum or p_last_forum is null) and (p_last_qid != p_qid or p_last_qid is null) THEN
-- This first round sets the values at the very top of a given set of data
  SET p_last_forum = p_forum;
  SET p_last_qid = p_qid;
  SET p_last_date = p_date;
  SET p_first_date = p_date;
  SET i=0;


  update WMD_Three set weight_in_minutes = timestampdiff(minute, p_date, `date`), row_type = 0
    where p_forum = forum and p_qid = qid;
  -- employing a specific classification scheme for replies to replies for later recalculation
  -- update WMD_Three set row_type = 2
    -- where p_forum = forum and p_qid = qid and replyTo not like "%top";
ELSE
   update WMD_Three set weight_in_minutes = timestampdiff(minute, p_date, `date`), row_type = 0
    where p_forum = forum and p_qid = qid and p_uniqueID = uniqueID;

   update WMD_Three set row_type = 2
    where p_forum = forum 
    and p_qid = qid 
    and replyTo not like "%top";

    SET p_last_forum = p_forum;
    SET p_last_qid = p_qid;
    SET p_last_date = p_date;

    INSERT into WMD_Three(
      uniqueID, 
      qid,
      title,
      poster,
      `date`,
      replyTo,
      content,
      forum,
      creator,
      row_type,
      weight_in_minutes)
    select 
      concat(uniqueID,"_", i),
      qid,
      title,
      poster,
      `date`,
      replyTo,
      content,
      forum,
      p_poster, -- basically, the creator of the "read" is the poster for the current row for everything before it ... 
      1,
      timestampdiff(minute, p_date, `date`)
      from
        WMD_Three
      where
        p_forum = forum 
        and p_qid = qid 
        and `date` > p_date
        and row_type = 0; 

     SET i=i+1;

    /* STILL MISSING: Direct Link subpost logic */


/*IF p_last_url != p_event_url or p_last_url is null THEN
       SET p_new_object_creator=p_event_author_id;
       SET p_last_url=p_event_url;
	  set first_date=p_event_date;
    set p_last_date=p_event_date;

		update cans_warehouse.events_stage 
		set object_creator=p_new_object_creator,parent_id=p_id,weight_in_minutes = 0
		where event_url = p_event_url
		and p_id = id
		AND event_action = event_action_create;

	      UPDATE cans_warehouse.events_stage
       SET object_creator = p_new_object_creator,parent_id=p_id,weight_in_minutes = timestampdiff(minute,p_event_date,event_date),row_type=0
       WHERE event_url = p_event_url
       AND event_action = event_action_read
       AND event_date >= p_event_date;
ELSE
 
 
		update cans_warehouse.events_stage
		set weight_in_minutes = timestampdiff(minute,p_last_date,p_event_date),
        object_creator=p_new_object_creator,parent_id=p_id
		where event_url = p_event_url
		and  id = p_id
		AND event_action = event_action_create;
    
     SET p_new_object_creator=p_event_author_id;
     SET p_last_url = p_event_url;
     set p_last_date = p_event_date;


  INSERT INTO cans_warehouse.events_stage
(id, environment_code, context_id, context_name, context_type, event_ip, event_session,
event_action, event_object, event_url, event_author_id, event_author_name, event_author_city,
event_author_state, event_author_zip_code, event_author_country, event_author_latitude,
event_author_longitude, event_date, object_creator,weight_in_minutes,row_type,parent_id)
SELECT id, environment_code, context_id, context_name, context_type, event_ip, event_session,
'jforum.read10', event_object, event_url, event_author_id, event_author_name, event_author_city,
event_author_state, event_author_zip_code, event_author_country, event_author_latitude,
event_author_longitude, event_date, p_new_object_creator, timestampdiff(minute,p_event_date,event_date),1,p_id
FROM cans_warehouse.events_stage WHERE event_url = p_last_url AND event_date > p_event_date AND event_action = event_action_read;
*/
END IF;

-- End of loop 
END LOOP loop_myCurse;

  insert into job(stuff) values("done!");
-- insert into events_archive select * from events_stage;

END