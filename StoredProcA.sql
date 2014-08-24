DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `weightme`()
BEGIN
-- Variable declaration

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
DECLARE myCurse CURSOR FOR SELECT uniqueID, qid, title, poster, `date`, replyTo, content, forum, creator
from WMD_Three order by forum, qid, `date` ASC;

DECLARE CONTINUE HANDLER FOR NOT FOUND
               SET no_more_rows = TRUE;

-- cursor is opened and looped through

-- opening and looping the cursor
OPEN myCurse;
loop_myCurse: LOOP
  fetch myCurse
    into p_uniqueID, p_qid, p_title, p_poster, p_date, p_replyTo, p_content, p_forum, p_creator;
  IF no_more_rows THEN
       CLOSE myCurse;
       LEAVE loop_myCurse;
  END IF;

IF (p_last_forum != p_forum or p_last_forum is null) and (p_last_qid != p_qid or p_last_qid is null) THEN
-- This first round sets the values at the very top of a given set of data
  SET p_last_forum = p_forum;
  SET p_last_qid = p_qid;
  SET p_last_date = p_date;
  SET p_first_date = p_date;
  SET i=0;


  update WMD_Three set weight_in_minutes = timestampdiff(minute, p_date, `date`), row_type = 0
    where p_forum = forum and p_qid = qid;

ELSE

-- This version seems to get the inserts right; but its doing a time delta on itself, so all the row types of zero 
-- have zero minutes for their time distance.
/*   update WMD_Three set weight_in_minutes = timestampdiff(minute, p_date, `date`), row_type = 0
    where p_forum = forum and p_qid = qid and p_uniqueID = uniqueID;*/



-- updated version of query above 
-- changed the date the weight in days is calculate from
   update WMD_Three set weight_in_minutes = timestampdiff(minute, p_first_date, `date`), row_type = 0
    where p_forum = forum and p_qid = qid and p_uniqueID = uniqueID;
-- end update

   update WMD_Three set row_type = 2 -- These are connections coded to indicate they are not responses to the "top" post but another user's post .. a deeper reply structure
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
      1, -- This makes it a "read reply"
      timestampdiff(minute, p_date, `date`)
      from
        WMD_Three
      where
        p_forum = forum 
        and p_qid = qid 
        and `date` > p_date
        and row_type = 0; -- filtering on row type zero means that we are not "exploding" the deeper reply structure items here ... (code 2)

     SET i=i+1;

    /* STILL MISSING: Direct Link subpost logic 
        This logic will take all the rows coded as "2" for row_type and loop through them much the same way as we do the others; but ignoring 
        everything coded as a "0" or "1"
    */

    

END IF;

-- End of loop 
END LOOP loop_myCurse;

  insert into job(stuff) values("done!");

END