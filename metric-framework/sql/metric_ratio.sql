set search_path = '%schema';

with num_metric as (
	select account_id, metric_time, metric_value as num_value
	from metric m inner join metric_name n on n.metric_name_id=m.metric_name_id
	and n.metric_name = '%num_metric'
	and metric_time between '%from_date' and '%to_date'
), den_metric as (
	select account_id, metric_time, metric_value as den_value
	from metric m inner join metric_name n on n.metric_name_id=m.metric_name_id
	and n.metric_name = '%den_metric'
	and metric_time between '%from_date' and '%to_date'
)

insert into metric (account_id,metric_time,metric_name_id,metric_value)

select d.account_id, d.metric_time, %metric_name_id,
	case when den_value > 0
	    then coalesce(num_value,0.0)/den_value
	    else %fill_val
    end as metric_value
from den_metric d  left outer join num_metric n
	on n.account_id=d.account_id
	and n.metric_time=d.metric_time;

