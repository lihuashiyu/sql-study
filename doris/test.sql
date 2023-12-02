show databases ;

set password for 'root' = password ('111111');
create user 'issac' identified by '111111';
grant all on test.* to issac;

show tables;


drop table if exists user_behavior;
create table if not exists user_behavior
(
    user_id          int        comment '用户ID：序列化后的用户ID，',
    goods_id         int        comment '商品ID：序列化后的商品ID，',
    item_category_id int        comment '商品类目ID：序列化后的商品所属类目ID，',
    behavior_type_id varchar(8) comment '行为类型：序列化后的用户ID；pv：商品详情页；pv：等价于点击，buy：商品购买，cart：将商品加入购物车，fav：收藏商品',
    timestamp        int        comment '行为发生的时间戳：序列化后的用户ID，'
) engine = InnoDB comment = '淘宝用户行为数据集';

drop table if exists view_user;
create table if not exists view_user
(
    id          int                   not null  comment '主键',
    user_id     varchar(32)           not null  comment '用户 ID',
    visit_date  varchar(32)           not null  comment '用户访问日期',
    visit_count bigint          not null  comment '用户访问次数'
)  comment '面试';

insert ignore into view_user (id, user_id, visit_date, visit_count)
values (101, 'u01', '2017/1/21', 5),
       (102, 'u02', '2017/1/23', 6),
       (103, 'u03', '2017/1/22', 8),
       (104, 'u04', '2017/1/20', 3),
       (105, 'u01', '2017/1/23', 6),
       (106, 'u01', '2017/2/21', 8),
       (107, 'u02', '2017/1/23', 6),
       (108, 'u01', '2017/2/22', 4);

-- 统计出 每个用户 每月访问次数 和 累积访问次数
select user_id                                                           as `用户 ID`,
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
