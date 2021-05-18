create view folder_commit_interval as
select
  id,
  message,
  folder,
  ROUND((julianday(author_when) - julianday(prev_commit_author_when)) * 24 * 60) as mins_since_prev_commit,
  author_when,
  prev_commit_author_when,
  prev_commit_id
from (
  with folder_commits as (
    select
      distinct folder,author_when,id,message
    from (
      select
        *,
        (CASE
           WHEN file LIKE 'nonprod-cluster/spring-app%' THEN 'nonprod'
           WHEN file LIKE 'prod-cluster/spring-app%' THEN 'prod'
           ELSE null
         END) as folder
      from commits
      left join stats
      on stats.commit_id = commits.id
    ) 
  ) 
  select 
    folder,
    author_when,
    id,
    message,
-- note: this is the previous commit *in the same folder*, which may well not be the previous commit
    (select author_when from folder_commits b where julianday(b.author_when)<julianday(folder_commits.author_when) and b.folder=folder_commits.folder order by julianday(b.author_when) desc limit 1) as prev_commit_author_when,
    (select id from folder_commits b where julianday(b.author_when)<julianday(folder_commits.author_when) and b.folder=folder_commits.folder order by julianday(b.author_when) desc limit 1) as prev_commit_id
  from folder_commits
  where prev_commit_author_when IS NOT NULL
  order by author_when desc
);

-- caution! if we have less than 10 data points per folder, per week, deciles will be populated incorrectly
create view folder_commit_interval_weekly_decile as 
select 
  p.folder,
  p.decile, 
  p.mins_since_prev_commit,
  strftime('%W', author_when) week_number,
  max(date(author_when, 'weekday 0', '-7 day')) as week_start
from (
  select 
     i.folder,
     i.author_when,
     i.mins_since_prev_commit, 
     ntile(10) over ( partition by folder,strftime('%W', author_when) order by mins_since_prev_commit ) decile
  from folder_commit_interval i
) as p
group by week_number,p.folder,p.decile;

create view folder_commit_interval_monthly_decile as 
select 
  p.folder,
  p.decile, 
  p.mins_since_prev_commit,
  strftime('%Y-%m', author_when) month
from (
  select 
     i.folder,
     i.author_when,
     i.mins_since_prev_commit, 
     ntile(10) over ( partition by folder,strftime('%Y-%m', author_when) order by mins_since_prev_commit ) decile
  from folder_commit_interval i
) as p
group by month,p.folder,p.decile;

