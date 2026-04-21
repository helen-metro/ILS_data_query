/*
*/

select *
from patron_v2
where bty in (8, 9, 10)
-- and expdate < TO_DATE('2026-01-01', 'YYYY-MM-DD') 
and state1 not like 'OK%' 
or state1 not like 'ok%'
or state1 not like 'Ok%'
and (state2 not like 'OK%' or state2 is null);


select to_char(transdate, 'YYYY-MM'), count(*)
from patronfiscal_v2
where amount = 7000
and notes = 'Annual Fee'
group by to_char(transdate, 'YYYY-MM')
order by to_char(transdate, 'YYYY-MM') desc;

select *
from patronfiscal_v2
where notes = 'Annual Fee'
order by transdate desc;