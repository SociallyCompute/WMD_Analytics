INSERT into WMD_Four(
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

-- df

INSERT INTO DW_Event_Fact(semester_id,time_id,institution_id,event_author_id,event_object_creator,
                          event_source_id,event_ip,
                          event_action,event_session,
                          event_context_id,event_url,event_object_id, 
                          weight_in_minutes,row_type,parent_id)
  SELECT  semester_id,
          time_id,
          10,
          (SELECT dpd.person_id
             FROM DW_Person_Dim dpd, bd_person bp
            WHERE bp.person_id = e.person_id
                  AND bp.sakai_id = dpd.person_sakai_id),
          (SELECT dpd.person_id
             FROM DW_Person_Dim dpd, bd_person bp
            WHERE bp.person_id = e.object_creator_person_id
                  AND bp.sakai_id = dpd.person_sakai_id),
          '1',
          e.events_ip,
          bea.event_actions_name,
          e.event_session,
          (SELECT dcd.context_id
             FROM DW_Context_Dim dcd, bd_context bc
            WHERE bc.context_id = e.context_id
                  AND bc.events_context_id = dcd.events_context_id),
          events_url,
          deo.event_object_id,
          e.weight_in_minutes,
          e.row_type,
          e.parent_id
     FROM DW_Semester_Dim dsd,
          bd_events e,
          DW_Time_Dim dtd,
          bd_event_actions bea,
          DW_Event_Object_Dim deo
    WHERE e.event_date BETWEEN dsd.semester_start_date
                           AND  dsd.semester_end_date
          AND dtd.datetime = e.event_date
          AND bea.event_actions_id = e.events_actions_id
          AND deo.Event_object_native_name = e.events_object_name
          AND deo.event_object_create_date = e.event_date