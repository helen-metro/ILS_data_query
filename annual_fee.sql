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

/* This part will cover the annual fee transactions*/
select *
from patronfiscal_v2
where (notes like '%Annual%' or notes like '%annual%')
order by transdate desc;

/* This part will call out all patrons classifed as Annual Fee Paying */
select *
from patron_v2
where bty in (8, 9, 10);


/* The merged view of patrons that classified as Annual Fee Paying  */
select *
from patron_v2 a
left join patronfiscal_v2 b on a.patronid = b.patronid
where bty in (8, 9, 10);


/*Transaction log of Annual Fee Paying patrons in pariod of time*/
select *
from txlog_v2 t
left join patron_v2 pa on t.patronid = pa.patronid
left join patronfiscal_v2 p on t.patronid = p.patronid
where pa.bty in (8, 9, 10)
and t.systemtimestamp >= TO_DATE('2025-01-01', 'YYYY-MM-DD');



/*The transactions by month of Annual Fee Paying patrons*/
select tx.transactiontype, 
tx.txtransdate,
tx.envbranch,
tx.pwd,
tx.termnumber,
tx.patronid, 
tx.patronbty,
tx.patronguid,
tx.itembranch,
tx.item,
tx.itemmedia,
tx.itemlocation,
tx.itemstatus,
tx.itemcn,
tx.txpickupbranch,
pa.bty,
pa.zip1,
pa.zip2,
pa.regdate,
pa.regbranch,
pa.state1,
pa.state2,
pf.amount,
pf.notes
from txlog_v2 tx
left join patron_v2 pa on pa.patronid = tx.patronid
left join patronfiscal_v2 pf on pf.patronid = tx.patronid
where pa.bty in (8, 9, 10)
and transactiontype in ('CH', 'RN')
and tx.SYSTEMTIMESTAMP >= to_date('2025-12-01', 'YYYY-MM-DD')
and tx.SYSTEMTIMESTAMP < to_date('2026-01-01', 'YYYY-MM-DD');