-- ---------------------------------------------------------------------------------------------------------------------
-- 同时在线人数问题：一个用户何时进入了一个直播间，又在何时离开了该直播间
-- 现要求统计各直播间最大同时在线人数
-- live_id   max_user_count
-- 1         4
-- 2         3
-- 3         2
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists live_events;
create table if not exists live_events
(
    user_id      int         comment '用户 ID',
    live_id      int         comment '直播 ID',
    in_datetime  varchar(64) comment '进入直播间时间',
    out_datetime varchar(64) comment '离开直播间时间'
) comment '直播间用户访问记录';

insert into live_events (user_id, live_id, in_datetime, out_datetime)
values (100, 1, '2021-12-01 19:00:00', '2021-12-01 19:28:00'),
       (100, 1, '2021-12-01 19:30:00', '2021-12-01 19:53:00'),
       (100, 2, '2021-12-01 21:01:00', '2021-12-01 22:00:00'),
       (101, 1, '2021-12-01 19:05:00', '2021-12-01 20:55:00'),
       (101, 2, '2021-12-01 21:05:00', '2021-12-01 21:58:00'),
       (102, 1, '2021-12-01 19:10:00', '2021-12-01 19:25:00'),
       (102, 2, '2021-12-01 19:55:00', '2021-12-01 21:00:00'),
       (102, 3, '2021-12-01 21:05:00', '2021-12-01 22:05:00'),
       (104, 1, '2021-12-01 19:00:00', '2021-12-01 20:59:00'),
       (104, 2, '2021-12-01 21:57:00', '2021-12-01 22:56:00'),
       (105, 2, '2021-12-01 19:10:00', '2021-12-01 19:18:00'),
       (106, 3, '2021-12-01 19:01:00', '2021-12-01 21:10:00');

select live_id,
       max(user_count) max_user_count
from
(
    select user_id,
           live_id,
           sum(user_change) over (partition by live_id order by event_time) as user_count
    from
    (
        select user_id,
               live_id,
               in_datetime as event_time,
               1           as user_change
        from live_events
        union all
        select user_id,
               live_id,
               out_datetime as event_time,
               -1 as user_change
        from live_events
    ) as t1
) as t2
group by live_id;


-- ---------------------------------------------------------------------------------------------------------------------
-- 会话划分问题：表中有每个用户的每次页面访问记录
-- 规定若同一用户的相邻两次访问记录时间间隔小于 60s，认为两次浏览记录属于同一会话，为属于同一会话的访问记录增加一个相同的会话 ID 字段
-- user_id   page_id      view_timestamp    session_id
-- 100       home         1659950435        100-1
-- 100       good_search  1659950446        100-1
-- 100       good_list    1659950457        100-1
-- 100       home         1659950541        100-2
-- 100       good_detail  1659950552        100-2
-- 100       cart         1659950563        100-2
-- 101       home         1659950435        101-1
-- 101       good_search  1659950446        101-1
-- 101       good_list    1659950457        101-1
-- 101       home         1659950541        101-2
-- 101       good_detail  1659950552        101-2
-- 101       cart         1659950563        101-2
-- 102       home         1659950435        102-1
-- 102       good_search  1659950446        102-1
-- 102       good_list    1659950457        102-1
-- 103       home         1659950541        103-1
-- 103       good_detail  1659950552        103-1
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists page_view_events;
create table if not exists page_view_events
(
    user_id        int         comment '用户id',
    page_id        varchar(64) comment '页面id',
    view_timestamp bigint      comment '访问时间戳'
) comment '页面访问浏览记录';

insert into page_view_events (user_id, page_id, view_timestamp)
values (100, 'home',        1659950435),
       (100, 'good_search', 1659950446),
       (100, 'good_list',   1659950457),
       (100, 'home',        1659950541),
       (100, 'good_detail', 1659950552),
       (100, 'cart',        1659950563),
       (101, 'home',        1659950435),
       (101, 'good_search', 1659950446),
       (101, 'good_list',   1659950457),
       (101, 'home',        1659950541),
       (101, 'good_detail', 1659950552),
       (101, 'cart',        1659950563),
       (102, 'home',        1659950435),
       (102, 'good_search', 1659950446),
       (102, 'good_list',   1659950457),
       (103, 'home',        1659950541),
       (103, 'good_detail', 1659950552),
       (103, 'cart',        1659950563);

select user_id,
       page_id,
       view_timestamp,
       concat(user_id, '-', sum(session_start_point) over (partition by user_id order by view_timestamp)) as session_id
from
(
    select user_id,
           page_id,
           view_timestamp,
           if(view_timestamp - lagts >= 60, 1, 0) as session_start_point
    from
    (
        select user_id,
               page_id,
               view_timestamp,
               lag(view_timestamp, 1, 0) over (partition by user_id order by view_timestamp) as lagts
        from page_view_events
    ) as t1
) as t2;


-- ---------------------------------------------------------------------------------------------------------------------
-- 间断连续登录用户问题：记录了一个用户何时登录了平台
-- 现要求统计各用户最长的连续登录天数，间断一天也算作连续，例如：一个用户在 1,3,5,6 登录，则视为连续 6 天登录
-- user_id    max_day_count
-- 100      3
-- 101      6
-- 102      3
-- 104      3
-- 105      1
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists login_events;
create table if not exists login_events
(
    user_id        int         comment '用户id',
    login_datetime varchar(64) comment '登录时间'
) comment '直播间访问记录';

insert into login_events (user_id, login_datetime)
values (100, '2021-12-01 19:00:00'),
       (100, '2021-12-01 19:30:00'),
       (100, '2021-12-02 21:01:00'),
       (100, '2021-12-03 11:01:00'),
       (101, '2021-12-01 19:05:00'),
       (101, '2021-12-01 21:05:00'),
       (101, '2021-12-03 21:05:00'),
       (101, '2021-12-05 15:05:00'),
       (101, '2021-12-06 19:05:00'),
       (102, '2021-12-01 19:55:00'),
       (102, '2021-12-01 21:05:00'),
       (102, '2021-12-02 21:57:00'),
       (102, '2021-12-03 19:10:00'),
       (104, '2021-12-04 21:57:00'),
       (104, '2021-12-02 22:57:00'),
       (105, '2021-12-01 10:01:00');

select user_id,
       max(recent_days) max_recent_days                                   -- 求出每个用户最大的连续天数
from
(
    select user_id,
           user_flag,
           datediff(max(login_date),min(login_date)) + 1 as recent_days   -- 按照分组求每个用户每次连续的天数(记得加1)
    from
    (
        select user_id,
               login_date,
               lag_date,
               concat(user_id,'_',flag) user_flag                         -- 拼接用户和标签分组
        from
        (
            select user_id,
                   login_date,
                   lag_date,
                   sum(if(datediff(login_date, lag_date) > 2, 1, 0)) over (partition by user_id order by login_date) as flag  -- 获取大于2的标签
            from
            (
                select user_id,
                       login_date,
                       lag(login_date,1,'1970-01-01') over(partition by user_id order by login_date) as lag_date  -- 获取上一次登录日期
                from
                (
                    select user_id,
                           date_format(login_datetime, 'yyyy-MM-dd') as login_date
                    from login_events
                    group by user_id, date_format(login_datetime, 'yyyy-MM-dd')  -- 按照用户和日期去重
                ) as t1
            ) as t2
        ) as t3
    ) as t4
    group by user_id, user_flag
) as t5
group by user_id;


-- ---------------------------------------------------------------------------------------------------------------------
-- 日期交叉问题：记录了每个品牌的每个优惠活动的周期，其中同一品牌的不同优惠活动的周期可能会有交叉
-- 现要求统计每个品牌的优惠总天数，若某个品牌在同一天有多个优惠活动，则只按一天计算
--  brand   promotion_day_count
--  vivo    17
--  oppo    16
--  redmi   22
--  huawei  22
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists promotion_info;
create table if not exists promotion_info
(
    promotion_id varchar(64) comment '优惠活动id',
    brand        varchar(64) comment '优惠品牌',
    start_date   varchar(64) comment '优惠活动开始日期',
    end_date     varchar(64) comment '优惠活动结束日期'
) comment '各品牌活动周期表';

insert into promotion_info (promotion_id, brand, start_date, end_date)
values (1, 'oppo',    '2021-06-05', '2021-06-09'),
       (2, 'oppo',    '2021-06-11', '2021-06-21'),
       (3, 'vivo',    '2021-06-05', '2021-06-15'),
       (4, 'vivo',    '2021-06-09', '2021-06-21'),
       (5, 'redmi',   '2021-06-05', '2021-06-21'),
       (6, 'redmi',   '2021-06-09', '2021-06-15'),
       (7, 'redmi',   '2021-06-17', '2021-06-26'),
       (8, 'huawei',  '2021-06-05', '2021-06-26'),
       (9, 'huawei',  '2021-06-09', '2021-06-15'),
       (10, 'huawei', '2021-06-17', '2021-06-21');

select brand,
       sum(datediff(end_date, start_date) + 1) as promotion_day_count
from
(
    select brand,
           max_end_date,
           if(max_end_date is null or start_date > max_end_date, start_date, date_add(max_end_date, 1)) as start_date,
           end_date
    from
    (
        select brand,
               start_date,
               end_date,
               max(end_date) over (partition by brand order by start_date rows between unbounded preceding and 1 preceding) as max_end_date
        from promotion_info
    ) as t1
) as t2
where end_date>start_date
group by brand;
