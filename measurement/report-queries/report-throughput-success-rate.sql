select
  nb_prod,
  nb_nonprod,
  ( 1.0 * sum(nb_prod) / sum(nb_nonprod) ) as promotion_rate 
from (
  select
    count(case when folder='prod' then 1 end) as nb_prod,
    count(case when folder='nonprod' then 1 end) as nb_nonprod
  from folder_commit_interval 
  where author_when > date('now', '-7 day')
);

--select
-- ( 1.0 * sum(nb_nonprod_reverts
