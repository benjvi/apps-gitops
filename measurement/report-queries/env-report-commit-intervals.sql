-- %%env%% should be interpolated as 'prod' or 'nonprod'
-- views are created, so lets query it
select "deployments in %%env%% in the last week";
.header on
.mode column

select *
from folder_commit_interval
where folder='%%env%%'
and author_when > date('now', '-7 day');

.header off
select "max/mean/min time between deployments in %%env%%";
.header on
select
  ( count(*) ) deployment_count,
  ( max(i.mins_since_prev_commit) / 60 ) max_interval_hours,
  ( avg(i.mins_since_prev_commit) / 60 )mean_interval_hours,
  ( min(i.mins_since_prev_commit) / 60 ) min_interval_hours,
  i.folder,
  strftime('%W', i.author_when) week_number,
  max(date(i.author_when, 'weekday 0', '-7 day')) as week_start
from folder_commit_interval i
where folder='%%env%%'
group by week_number,folder;

.header off
select "median time between deployments in %%env%% each week";
.header on
select a.* 
from folder_commit_interval_weekly_decile a
inner join (
  select 
    max(decile) max_decile,
    week_number
  from folder_commit_interval_weekly_decile
  where folder='%%env%%'
  group by week_number
) b
on b.week_number = a.week_number
where decile = round( b.max_decile / 2 )
and folder='%%env%%';

.header off
select "median time between deployments in %%env%% each month";
.header on
select a.* 
from folder_commit_interval_monthly_decile a
inner join (
  select 
    max(decile) max_decile,
    month
  from folder_commit_interval_monthly_decile
  where folder='%%env%%'
  group by month
) b
on b.month = a.month
where decile = round( b.max_decile / 2 )
and folder='%%env%%';


.header off
select "deciles of interval times between deployments in the last week";
.header on
select a.*
from folder_commit_interval_weekly_decile a
inner join (
  select max(week_number) max_week_no
  from folder_commit_interval_weekly_decile 
) b
on a.week_number = b.max_week_no
where folder='%%env%%';

/*
.header off
select "deciles of interval times between deployments in the previous week";
.header on
select a.*
from folder_commit_interval_decile a
inner join (
  select max(week_number) max_week_no
  from folder_commit_interval_decile 
  where week_number < ( SELECT MAX(week_number) FROM folder_commit_interval_decile )
) b
on a.week_number = b.max_week_no
where folder='%%env%%';
*/
