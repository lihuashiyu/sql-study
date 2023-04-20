show tables;

drop table if exists view_user;
create table if not exists view_user
(
    id          int                   not null  comment '主键',
    user_id     varchar(32)           not null  comment '用户 ID',
    visit_date  varchar(32)           not null  comment '用户访问日期',
    visit_count bigint          not null  comment '用户访问次数'
)  comment '面试';

insert ignore into view_user (id, user_id, visit_date, visit_count) values (101, 'u01', '2017/1/21', 5);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (102, 'u02', '2017/1/23', 6);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (103, 'u03', '2017/1/22', 8);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (104, 'u04', '2017/1/20', 3);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (105, 'u01', '2017/1/23', 6);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (106, 'u01', '2017/2/21', 8);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (107, 'u02', '2017/1/23', 6);
insert ignore into view_user (id, user_id, visit_date, visit_count) values (108, 'u01', '2017/2/22', 4);

-- 统计出 每个用户 每月访问次数 和 累积访问次数
select
       user_id                                                           as `用户 ID`,
       visit_month                                                       as `月份`,
       sum                                                               as `小计`,
       sum(t1.sum) over(partition by t1.user_id order by t1.visit_month) as `累计`
from
(
    select user_id,
           visit_month,
           sum(t2.visit_count) as sum
    from
    (
        select user_id,
               from_unixtime(unix_timestamp(t3.visit_date), '%Y-%m') as visit_month,
               visit_count
        from view_user as t3
    ) as t2 group by user_id, visit_month
) as t1 order by user_id, visit_month;
