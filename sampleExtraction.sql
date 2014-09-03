select poster as "source", creator as "target", round((log((1+(1/weight_in_minutes)))*10000), 4) as weight
from WMD_Three
where month(date) = 1 and year(date) = 2010 and qid != -1 and creator is not null
group by poster, creator
order by qid, localID, date  