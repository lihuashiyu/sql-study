-- -------------------------------------------------------------------------------------------------
-- rank()      ：排序相同时会重复，总数不变，        即会出现 1、1、3 这样的排序结果；
-- dense_rank()：排序相同时会重复，总数会减少，      即会出现 1、1、2 这样的排序结果；
-- row_number()：排序相同时不会重复，会根据顺序排序，即会出现 1、2、3 这样的排序结果；

-- row_number：得到的列别名可用于 order by 排序，因为 order by 执行在 select 之后
--             where, group by, having 都不可引用该列，因为这些语句执行在 select 之前，此时尚未计算出值
-- -------------------------------------------------------------------------------------------------
drop table if exists row_no;
create table if not exists row_no
(
    id     int        primary key  comment '主键',
    user   varchar(4) not null     comment '用户',
    name   varchar(4) not null     comment '名称',
    age    int        not null     comment '年龄',
    salary int        not null     comment '工资'
);

insert ignore into row_no (id, user, name, age, salary)
values (101, 'u1', 'a1', 10, 8000),
       (102, 'u1', 'a2', 11, 7500),
       (103, 'u2', 'b1', 12, 7500),
       (104, 'u2', 'b2', 13, 4500),
       (105, 'u3', 'c1', 14, 8000),
       (106, 'u3', 'c2', 15, 20000),
       (107, 'u4', 'd1', 16, 30000),
       (108, 'u5', 'd2', 17, 8000);

-- rank()
select *, rank() over(order by salary) as `rank` from row_no;

-- dense_rank()
select *, dense_rank() over(order by salary) as `dense_rank` from row_no;

-- row_number()
select *, row_number() over(order by salary) as `row_number` from row_no;


drop database if exists test;
create database if not exists test;
use test;
show tables;

-- -------------------------------------------------------------------------------------------------
-- lag()：函数是一个窗口函数，回顾多行并从当前行访问行的数据

-- LAG(<expression>[, offset[, default_value]]) OVER ( PARTITION BY expr, ... ORDER BY expr [ASC|DESC], ... )

-- expression：lag() 函数返回 expression 当前行之前的行的值，其值为 offset 其分区或结果集中的行数

-- offset：从当前行返回的行数，以获取值，offset 必须是零或文字正整数；
--            如果 offset 为零，则 LAG() 函数计算 expression 当前行的值;
--            如果未指定 offset，则 LAG() 默认情况下函数使用一个

-- default_value：如果没有前一行，则 lag() 函数返回 default_value
--                    如果 offset 为 2，则第一行的返回值为 default_value;
--                    如果省略 default_value，则默认 lag() 返回函数 null

-- partition by：将结果集中的行划分 lag() 为应用函数的分;
--                   如果省略 partition by 子句，lag() 函数会将整个结果集视为单个分区

-- order by：指定在 lag() 应用函数之前每个分区中的行的顺序

-- lag() 函数可用于计算当前行和上一行之间的差异
-- -------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------
-- 1. HiveSQl 连续登录问题：
-- 用户    访问时间
-- u01    2022-10-21
-- u01    2022-10-21
-- u02    2022-10-21
-- u03    2022-10-21
-- u04    2022-10-21
-- -------------------------------------------------------------------------------------------------
drop table if exists user_login_info;
create table if not exists user_login_info
(
    id          int primary key  comment '主键',
    user_id     varchar(32) not null     comment '用户 ID',
    login_date  date        not null     comment '用户访问时间',
    status      int         not null      comment '在线状态：0，离线；1，在线'
) engine = InnoDB character set = 'utf8mb4' comment '面试';

insert ignore into user_login_info (`id`, `user_id`, login_date, status)
values (101, 'u01', '2021-10-21', 1),
       (102, 'u02', '2021-10-21', 1),
       (103, 'u03', '2021-10-21', 1),
       (104, 'u04', '2021-10-21', 1),
       (105, 'u01', '2021-10-22', 1),
       (106, 'u02', '2021-10-22', 1),
       (107, 'u03', '2021-10-22', 1),
       (108, 'u04', '2021-10-22', 1),
       (109, 'u01', '2021-10-23', 1),
       (110, 'u02', '2021-10-23', 1),
       (111, 'u03', '2021-10-23', 1),
       (112, 'u02', '2021-10-24', 1),
       (113, 'u03', '2021-10-24', 1),
       (114, 'u01', '2021-10-25', 1),
       (115, 'u02', '2021-10-25', 1),
       (116, 'u03', '2021-10-25', 1),
       (117, 'u01', '2021-10-26', 1),
       (118, 'u02', '2021-10-26', 1),
       (119, 'u04', '2021-10-26', 1),
       (120, 'u03', '2021-10-27', 1);

-- 统计连续 N 天登录的用户信息 Top3
select u.user_id,
       count(*) as day_count                               -- 按照用户分组，按照日期递增排序，计算连续登录操作的锚定日期
from
(
    select t.user_id,
           t.login_date,                                     -- 查询用户在起始日期及其之后的连续登录次数
           date_sub(t.login_date, interval t.row_no day) as group_id      -- 排序 row_no 产生分组
    from
        (
        select user_id,
               login_date,
               row_number() over (partition by user_id order by login_date) as row_no -- 使用 row_number 进行排序
        from user_login_info
        where status = 1 -- 筛选状态为登录
        ) as t
) as u
group by u.user_id, u.group_id                             -- 按照用户、锚定日期分组
having day_count >= 3;                                     -- 筛选出至少 3 次的连续登录操作

-- 每个用户连续登录的最长天数，间隔一天的两次登录也可以看作连续登录
select t4.user_id,
       max(t4.day_count) as max_login_day
from
(
    -- 按照用户 user_id、flag 字段分组，计算登录日期的最大值、最小值之差，表示一次连续登录的天数
    select t3.user_id,
           datediff(max(t3.login_date), min(t3.login_date)) + 1 as day_count
    from
    (
        -- 按照 user_id 分组，按照登录日期递增排序，判断当前登录、上次登录的日期之差是否大于 2，累计求和，
        -- 使得属于连续登录的所有日期具有相同取值的 flag 字段
        select t2.user_id,
               t2.login_date,
        sum(if(diff > 2, 1, 0)) over(partition by t2.user_id order by t2.login_date) as flag
        from
        (
            -- 查询当前登录、上次登录的日期之差 diff
            select t1.user_id,
                   t1.login_date,
            case
                when pre_day is null then 0
                else                      datediff(t1.login_date, t1.pre_day)
            end                                                               as diff
            from
            (    -- 按照 user_id 分区，按照登录日期递增排序，查询当前登录日期、上次登录日期
                select user_id,
                       login_date,
                       lag(login_date) over(partition by user_id order by login_date) as pre_day
                from user_login_info
                where status = 1
            ) as t1
        ) as t2
    ) as t3 group by t3.user_id, t3.flag
) as t4 group by t4.user_id;


-- -------------------------------------------------------------------------------------------------
-- 1. HiveSQl 连续登录问题：
-- 年份    冠军队
-- 2000    Sun
-- 2001    Lakers
-- 2002    Rockets
-- 2003    Rockets
-- 2004    Rockets
-- 2005    Spurs
-- 2006    Spurs
-- 2007    Sun
-- 2008    Lakers
-- 2009    Lakers
-- 2010    Lakers
-- 2011    Lakers
-- 2012    Warriors
-- 2013    Warriors
-- 2014    Warriors
-- 2015    Heat
-- 2016    Warriors
-- 2017    Cavaliers
-- 2018    Warriors
-- 2019    Sun
-- 2020    Warriors
-- 2021    Warriors
-- 2022    Raptors
-- -------------------------------------------------------------------------------------------------
drop table if exists champion;
create table if not exists champion
(
    year   int          primary key  comment '年份',
    team   varchar(16)  not null     comment '冠军队伍'
) engine = InnoDB character set = 'utf8mb4' comment '冠军表';

insert ignore into champion (year, team)
values (2000, 'Sun'),
       (2001, 'Lakers'),
       (2002, 'Rockets'),
       (2003, 'Rockets'),
       (2004, 'Rockets'),
       (2005, 'Spurs'),
       (2006, 'Spurs'),
       (2007, 'Sun'),
       (2008, 'Lakers'),
       (2009, 'Lakers'),
       (2010, 'Lakers'),
       (2011, 'Lakers'),
       (2012, 'Warriors'),
       (2013, 'Warriors'),
       (2014, 'Warriors'),
       (2015, 'Heat'),
       (2016, 'Warriors'),
       (2017, 'Cavaliers'),
       (2018, 'Warriors'),
       (2019, 'Sun'),
       (2020, 'Warriors'),
       (2021, 'Warriors'),
       (2022, 'Raptors');

-- 连续 3 年获得冠军的队伍
select u.team,                                             -- 查询队伍在起始年份及其之后的连续获得冠军的次数
       min(u.year)        as start_year,
       count(u.different) as count
from
(    -- 按照队伍分组，按照年份递增排序，计算队伍获得冠军的锚定年份
    select t.year,
           t.team,
           t.year - t.row_no as different
    from
    (   -- 按照队伍分组，按照年份递增排序，计算队伍获得冠军的锚定年份
        select year,
               team,
               row_number() over (partition by team order by year) as row_no
        from champion
    ) as t
) as u
group by u.team, u.different                               -- 按照队伍、锚定年份分组
having count >= 3                                          -- 筛选出至少 3 次的连续获得冠军
order by start_year;


-- -------------------------------------------------------------------------------------------------
-- 股票价格在时间点上的波峰与波谷
--  股票ID   时间点   价格
--    A1     06:00    12
--    A1     09:00    16
--    A1     12:00    24
--    A1     15:00    17
--    A1     18:00    11
--    A1     21:00    13
--    B1     06:00    18
--    B1     09:00    12
--    B1     12:00    13
--    B1     15:00    13
--    B1     18:00    15
--    B1     21:00    17
--    C1     06:00    12
--    C1     09:00    13
--    C1     12:00    15
--    C1     15:00    17
--    C1     18:00    18
--    C1     21:00    20
-- -------------------------------------------------------------------------------------------------
drop table if exists equities_price;
create table if not exists equities_price
(
    id    int           primary key comment '主键',
    stock varchar(4)    not null    comment '股票名称',
    time  varchar(8)    not null    comment '交易时间',
    price decimal(3, 0) not null    comment '交易价格'
) engine = InnoDB character set = 'utf8mb4' comment '股票交易表';

insert ignore into equities_price (id, stock, time, price)
values (101, 'A1', '06:00', 12),
       (102, 'A1', '09:00', 16),
       (103, 'A1', '12:00', 24),
       (104, 'A1', '15:00', 17),
       (105, 'A1', '18:00', 11),
       (106, 'A1', '21:00', 13),
       (107, 'B1', '06:00', 18),
       (108, 'B1', '09:00', 12),
       (109, 'B1', '12:00', 13),
       (110, 'B1', '15:00', 13),
       (111, 'B1', '18:00', 15),
       (112, 'B1', '21:00', 17),
       (113, 'C1', '06:00', 12),
       (114, 'C1', '09:00', 13),
       (115, 'C1', '12:00', 15),
       (116, 'C1', '15:00', 17),
       (117, 'C1', '18:00', 18),
       (118, 'C1', '21:00', 20);

-- 查询波峰点和波谷
select v.stock,
       v.time,
       v.price,
       v.status
from
(
    -- 查询波峰点
    select t.stock,
           t.time,
           t.price,
           'top' as status
    from
    (
        select stock,
               time,
               price,
               -- 按照股票分组，按照时间点递增排序
               lag(price)  over(partition by stock order by time) as previous, -- 前面时间点的价格
               lead(price) over(partition by stock order by time) as next      -- 后面时间点的价格
        from equities_price
    ) t where t.price > t.previous and t.price > t.next                       -- 筛选出波峰点
    union
    select d.stock,                                                     -- 查询波谷点
           d.time,
           d.price,
           'down' as status
    from
    (
        select stock,
               time,
               price,
               lag(price)  over(partition by stock order by time) as previous,
               lead(price) over(partition by stock order by time) as next
        from equities_price
    ) as d where d.price < d.previous and d.price < d.next                   -- 筛选出波谷点
) as v;


-- -------------------------------------------------------------------------------------------------
-- 给定用户点击浏览记录，如果两次点击浏览的时间间隔不超过 30 个单位，则两次浏览属于相同的会话
--     查询用户在每次会话中的浏览时长、浏览步长，步长表示点击浏览的次数
--  用户   点击时间
--   a      1001
--   a      1005
--   a      1020
--   a      1048
--   a      1078
--   a      1230
--   a      1245
--   a      1270
--   a      1282
--   b      1101
--   b      1132
--   b      1156
--   b      1180
--   b      1200
--   b      1230
--   b      1345
--   b      1370
--   b      1400
-- -------------------------------------------------------------------------------------------------
drop table if exists user_glance_info;
create table if not exists user_glance_info
(
    id      int        primary key comment '主键',
    user_id varchar(4) not null    comment '用户 ID',
    time    int        not null    comment '浏览时间',
    event   int        not null    comment '触发事件：0，点击；1，双击；2，回车'
) engine = InnoDB character set = 'utf8mb4' comment '用户浏览信息表';

insert ignore into user_glance_info (id, user_id, time, event)
values (101, 'a', 1001, 0),
       (102, 'a', 1005, 0),
       (103, 'a', 1020, 0),
       (104, 'a', 1048, 0),
       (105, 'a', 1078, 0),
       (106, 'a', 1230, 0),
       (107, 'a', 1245, 0),
       (108, 'a', 1270, 0),
       (109, 'a', 1282, 0),
       (110, 'b', 1101, 0),
       (111, 'b', 1132, 0),
       (112, 'b', 1156, 0),
       (113, 'b', 1180, 0),
       (114, 'b', 1200, 0),
       (115, 'b', 1230, 0),
       (116, 'b', 1345, 0),
       (117, 'b', 1370, 0),
       (118, 'b', 1400, 0);

-- 查询用户在每次会话中的浏览时长、浏览步长，步长表示点击浏览的次数
select t3.user_id,
       min(t3.time)                as start_time,
       count(t3.user_id)           as count,
       max(t3.time) - min(t3.time) as total_time
from
(
    -- 分组排序后，从上到下计算 value 列的累加和，如果求和结果相同，则表示属于相同的会话
    select t2.user_id,
           t2.time,
           sum(t2.flag) over (partition by t2.user_id order by t2.time) as stage
    from
    (
        -- 如果与前一次点击的时间之差超过 30，则 value 列为 1，否则为 0
        -- value 列为 1 表示这次点击属于一个新的会话，为 0 表示这次点击与前一次属于相同的会话
        select t1.user_id,
               t1.time, if(nullif(t1.time - t1.previous, 9999) > 30, 1, 0) as flag
        from
        (
            -- 按照用户 id 分组，按照点击浏览时间递增排序，计算前后两次点击的时间之差
            select user_id,
                   time,
                   lag(time) over (partition by user_id order by time) as previous
            from user_glance_info
            where event = 0
        ) as t1
    ) as t2
) as t3 group by t3.user_id, t3.stage;


-- -------------------------------------------------------------------------------------------------
-- 每个品牌具有多个打折活动，给定每个活动的开始时间、结束时间，返回每个品牌实际参与打折的天数，重复日期不计算在内
-- 品牌ID  活动开始时间   活动结束时间
-- 1001    2022-07-01     2022-07-03
-- 1001    2022-07-05     2022-07-10
-- 1002    2022-07-02     2022-07-08
-- 1002    2022-07-06     2022-07-09
-- 1003    2022-07-12     2022-07-20
-- 1003    2022-07-15     2022-07-18
-- 1004    2022-07-20     2022-07-25
-- 1004    2022-07-22     2022-07-26
-- 1004    2022-07-28     2022-07-30
-- -------------------------------------------------------------------------------------------------
drop table if exists discount_info;
create table if not exists discount_info
(
    id         int  primary key comment '主键',
    brand      int  not null    comment '品牌 ID',
    start_date date not null    comment '活动开始日期',
    end_date   date not null    comment '活动结束日期'
) engine = InnoDB character set = 'utf8mb4' comment '用户浏览信息表';

insert ignore into discount_info (id, brand, start_date, end_date)
values (101, 1001, '2022-07-01', '2022-07-03'),
       (102, 1001, '2022-07-05', '2022-07-10'),
       (103, 1002, '2022-07-02', '2022-07-08'),
       (104, 1002, '2022-07-06', '2022-07-09'),
       (105, 1003, '2022-07-12', '2022-07-20'),
       (106, 1003, '2022-07-15', '2022-07-18'),
       (107, 1004, '2022-07-20', '2022-07-25'),
       (108, 1004, '2022-07-22', '2022-07-26'),
       (109, 1004, '2022-07-28', '2022-07-30');


-- -------------------------------------------------------------------------------------------------
-- rows between ... preceding and ... following ：在 XXX 之前和 XXX 之后的所有记录
--
-- unbounded           ： 无边界
-- preceding           ： 往前
-- following           ： 往后
-- unbounded preceding ： 往前所有行，即初始行
-- n preceding         ： 往前 n 行
-- unbounded following ： 往后所有行，即末尾行
-- n following         ： 往后 n 行
-- current row         ： 当前行
--
-- (ROWS | RANGE) BETWEEN (UNBOUNDED | [num]) PRECEDING AND ([num] PRECEDING | CURRENT ROW | (UNBOUNDED | [num]) FOLLOWING)
-- (ROWS | RANGE) BETWEEN CURRENT ROW AND (CURRENT ROW | (UNBOUNDED | [num]) FOLLOWING)
-- (ROWS | RANGE) BETWEEN [num] FOLLOWING AND (UNBOUNDED | [num]) FOLLOWING
--
-- rows between ... and ...
--         rows：指以行号来决定 frame 的范围，是物理意义上的行，
--              比如 rows between 1 preceding and 1 following：代表从当前行往前一行以及往后一行
--
-- range between ... and ...
--         range：指以当前行在开窗函数中的值为根基，然后按照 order by 进行排序，最后根据 range 去加减上下界，是逻辑意义上的行
--                比如 sum(score) over (PARTITION by id order by score ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)：
--                      表示按照 id 分组，按照 score 升序排序，然后以当前行的 score，
--                          下界减一，上界加一，作为范围，将这范围里的score进行加总
-- -------------------------------------------------------------------------------------------------

-- 每个品牌实际参与打折的天数，重复日期不计算在内
select v.brand,
       sum(v.count) as day_count
from
(    -- 根据当前结束时间的最大值 max_date，计算每行打折活动可以贡献的活动天数 count
    select t.brand,
           t.start_date,
           t.end_date,
           t.max_date,
           case
               when t.max_date is null        then datediff(t.end_date, t.start_date) + 1
               when t.max_date < t.start_date then datediff(t.end_date, t.start_date) + 1
               when t.max_date < t.end_date   then datediff(t.end_date, t.max_date)
               else                            0
           end                                                                     as count
    from
    (   -- 按照品牌分组，按照开始时间、结束时间递增排序，查询当前结束时间的最大值 max_date
        select brand,
               start_date,
               end_date,
               max(end_date) over (partition by brand order by start_date, end_date rows between unbounded preceding and 1 preceding) as max_date
        from discount_info
    ) as t
) as v group by v.brand;


-- -------------------------------------------------------------------------------------------------
-- 给定每个用户在线的开始时间、结束时间，返回一个时间段与人数，这个时间段具有最多的在线人数
-- 用户ID   开始时间     结束时间
--  1001   2022-07-01   2022-07-02
--  1001   2022-07-04   2022-07-05
--  1001   2022-07-07   2022-07-10
--  1001   2022-07-13   2022-07-18
--  1002   2022-07-01   2022-07-02
--  1002   2022-07-04   2022-07-05
--  1002   2022-07-07   2022-07-08
--  1002   2022-07-10   2022-07-11
--  1002   2022-07-13   2022-07-14
--  1002   2022-07-16   2022-07-17
--  1002   2022-07-19   2022-07-20
--  1003   2022-07-01   2022-07-20
--  1004   2022-07-04   2022-07-08
--  1004   2022-07-12   2022-07-16
--  1005   2022-07-03   2022-07-06
--  1005   2022-07-09   2022-07-11
--  1006   2022-07-04   2022-07-06
--  1007   2022-07-09   2022-07-12
--  1008   2022-07-06   2022-07-08
--  1008   2022-07-11   2022-07-13
--  1009   2022-07-06   2022-07-08
--  1009   2022-07-18   2022-07-19
--  1010   2022-07-11   2022-07-14
-- -------------------------------------------------------------------------------------------------
drop table if exists live;
create table if not exists live
(
    id         int  primary key comment '主键',
    user_id    int  not null    comment '用户 ID',
    start_date date not null    comment '开始日期',
    end_date   date not null    comment '结束日期'
) engine = InnoDB character set = 'utf8mb4' comment '用户登录退出表';

insert ignore into live (id, user_id, start_date, end_date)
values (101, '1001', '2022-07-01', '2022-07-02'),
       (102, '1001', '2022-07-04', '2022-07-05'),
       (103, '1001', '2022-07-07', '2022-07-10'),
       (104, '1001', '2022-07-13', '2022-07-18'),
       (105, '1002', '2022-07-01', '2022-07-02'),
       (106, '1002', '2022-07-04', '2022-07-05'),
       (107, '1002', '2022-07-07', '2022-07-08'),
       (108, '1002', '2022-07-10', '2022-07-11'),
       (109, '1002', '2022-07-13', '2022-07-14'),
       (110, '1002', '2022-07-16', '2022-07-17'),
       (111, '1002', '2022-07-19', '2022-07-20'),
       (112, '1003', '2022-07-01', '2022-07-20'),
       (113, '1004', '2022-07-04', '2022-07-08'),
       (114, '1004', '2022-07-12', '2022-07-16'),
       (115, '1005', '2022-07-03', '2022-07-06'),
       (116, '1005', '2022-07-09', '2022-07-11'),
       (117, '1006', '2022-07-04', '2022-07-06'),
       (118, '1007', '2022-07-09', '2022-07-12'),
       (119, '1008', '2022-07-06', '2022-07-08'),
       (120, '1008', '2022-07-11', '2022-07-13'),
       (121, '1009', '2022-07-06', '2022-07-08'),
       (122, '1009', '2022-07-18', '2022-07-19'),
       (123, '1010', '2022-07-11', '2022-07-14');

select dt,
       online
from 
(
    select dt,
           sum(count) over(order by dt) as online
    from
    (
        select dt,
               sum(value) as count
        from
        (
            select id,
                   start_date            as dt,
                   1                     as value
            from live
            union
            select id,
                   date_add(end_date, 1) as dt,
                   -1                    as value
            from live
        ) t1 group by dt
    ) t2
) t3
order by online desc, dt;


-- -------------------------------------------------------------------------------------------------
-- 给定多个时间段，每个时间段分为开始时间、结束时间，将相互重叠的多个时间段合并为一个区间
-- id  开始时间 结束时间
-- 1      12      15
-- 2      57      58
-- 3      29      32
-- 4      30      31
-- 5      17      19
-- 6      44      44
-- 7      56      57
-- 8      16      18
-- -------------------------------------------------------------------------------------------------
drop table if exists time_merge;
create table if not exists time_merge
(
    id         int  primary key comment '主键',
    start_time int not null     comment '开始时间',
    end_time   int not null     comment '结束时间'
) engine = InnoDB character set = 'utf8mb4' comment '用户开始结束时间表';

insert ignore into time_merge (id, start_time, end_time)
values (1, 12, 15),
       (2, 57, 58),
       (3, 29, 32),
       (4, 30, 31),
       (5, 17, 19),
       (6, 44, 44),
       (7, 56, 57),
       (8, 16, 18);

-- 按照区间序号进行分组，查询每个分组的最小开始时间作为区间开始时间，最大结束时间作为区间结束时间
select flag,
       min(start_time) as start_time,
       max(end_time) as end_time
from
(    -- 判断哪些时间段属于相同区间，flag表示时间段归属的区间序号，值相同表示属于相同区间
    select id,
           start_time,
           end_time,
    sum(count) over(order by start_time, end_time) as flag
    from
    (   -- 根据当前结束时间的最大值 max_dt进行比较，标记每个时间段是否为新的区间
        select id,
               start_time,
               end_time,
               case
                   when max_dt is null      then 1 -- 作为一个新的区间
                   when max_dt < start_time then 1 -- 作为一个新的区间
                   else                          0
               end         as count -- 与前面的区间具有重叠
        from
        (   -- 按照开始时间、结束时间递增排序，查询当前结束时间的最大值max_dt
            select id,
                   start_time,
                   end_time,
                   max(end_time) over (order by start_time, end_time rows between unbounded preceding and 1 preceding) as max_dt
            from time_merge
        ) t1
    ) t2
) t3 group by flag;


-- -------------------------------------------------------------------------------------------------
-- 给定每个用户的好友列表，好友关系是互相对称的，返回任意两个用户的共同好友列表
-- 用户ID  好友ID列表
--   A      B,C,D
--   B      A,C,E
--   C      A,B,D,E,F
--   D      A,C,F
--   E      B,C
--   F      C,D
-- -------------------------------------------------------------------------------------------------
drop table if exists friend;
create table if not exists friend
(
    id       int         primary key comment '主键',
    user_id  varchar(2)  not null    comment '用户 ID',
    friends  varchar(16) not null    comment '好友列表'
) engine = InnoDB character set = 'utf8mb4' comment '用户好友列表';

insert ignore into friend (id, user_id, friends)
values (101, 'A', 'B,C,D'),
       (102, 'B', 'A,C,E'),
       (103, 'C', 'A,B,D,E,F'),
       (104, 'D', 'A,C,F'),
       (105, 'E', 'B,C'),
       (106, 'F', 'C,D');

-- 按照用户的两两组合进行分组，将所有的共同好友放入列表
select t1.ids,
       concat_ws(',', collect_list(t1.friend)) as common_friend
from
(   -- 将好友关系表与自身进行连接，查询每个用户是哪两个用户的共同好友
    select a.friends,
           concat(a.id, ',', b.id) as ids
    from friend a join friend b
        on a.friends = b.friends            -- 按照共同好友进行连接
    where a.id < b.id                       -- 筛选出重复记录
) t1 group by t1.ids;

-- 每个用户的可能好友：如果两个用户不是好友关系，并且两者拥有至少一个（或者两个）共同好友，则两者互相是可能好友
-- 创建临时表，将好友关系分解为最细粒度
with friend as
(
    select id,
           friends
    from friend lateral view explode(split(friends, ',')) temp as friend
)
-- 将具有至少两个共同好友的临时表与好友关系表进行连接，如果临时表的两个用户是好友关系，则在好友关系表中存在对应记录，
-- 否则不存在对应记录，表示两者是可能好友
select t2.id1,
       t2.id2
from
(
    -- 查询具有至少两个共同好友的任意两个用户
    select t1.id1,
           t1.id2
    from
    (   -- 将好友关系表与自身进行连接，查询任意两个用户具有的共同好友
        select a.id as id1,
               b.id as id2,
               a.friend
        from friend a join friend b
            on a.friend = b.friend
        where a.id < b.id
    ) t1 group by t1.id1, t1.id2 having count(t1.friend) >= 2
) t2 left join friend
         on  t2.id1 = friend.id
         and t2.id2 = friend.friend
where friend.id is null; -- 排除真实好友，筛选可能好友


-- -------------------------------------------------------------------------------------------------
-- 给定一个用户购买一次商品的记录，返回每个用户可能想要购买的商品。如果其余用户与这个用户购买至少两个相同的商品，则其余用户购买、这个用户没有购买的商品，就是这个用户可能想要购买的商品
-- 用户ID、商品ID
--   A      1
--   A      2
--   A      1
--   A      3
--   B      2
--   B      3
--   B      4
--   B      5
--   B      2
--   C      1
--   C      2
--   C      1
--   D      1
--   D      3
--   D      6
-- -------------------------------------------------------------------------------------------------
drop table if exists shop;
create table if not exists shop
(
    id        int         primary key comment '主键',
    user_id   varchar(2)  not null    comment '用户 ID',
    product   int         not null    comment '商品 ID'
) engine = InnoDB character set = 'utf8mb4' comment '用户购买商品记录';

insert ignore into shop (id, user_id, product)
values (101 , 'A', 1),
       (102 , 'A', 2),
       (103 , 'A', 1),
       (104 , 'A', 3),
       (105 , 'B', 2),
       (106 , 'B', 3),
       (107 , 'B', 4),
       (108 , 'B', 5),
       (109 , 'B', 2),
       (110 , 'C', 1),
       (111 , 'C', 2),
       (112 , 'C', 1),
       (113 , 'D', 1),
       (114 , 'D', 3),
       (115 , 'D', 6);

-- 按照用户、商品进行分组、去重
with temp as
(
    select id,
           product
    from shop
    group by id, product
)
-- 将已购买与推荐购买的临时表与已购买表进行连接，如果临时表的商品已购买，则在已购买表中存在对应记录，否则不存在对应记录，表示推荐商品
select t4.id1 as id,
       t4.product
from
(   -- 查询每个用户已购买与推荐购买的商品
    select t3.id1,
           t3.product
    from
    (   -- 查询每个用户、以及具有相同购买倾向的其余用户、其余用户已购买的商品
        select t2.id1,
               t2.id2,
               temp.product
        from
        (   -- 查询已购买至少两个相同商品的任意两个用户
            select t1.id1,
                   t1.id2
            from
            (   -- 查询已购买相同商品的任意两个用户
                select a.id as id1,
                       b.id as id2,
                       a.product
                from temp a join temp b
                     on  a.product = b.product
                     and a.id     != b.id
            ) t1 group by t1.id1, t1.id2
                 having count(t1.product) >= 2
        ) t2 join temp on t2.id2 = temp.id
    ) t3 group by t3.id1, t3.product
) t4 left join temp
         on  t4.product = temp.product
         and t4.id1    = temp.id                 -- 相同用户购买相同商品
where temp.product is null;                      -- 排除已购买商品，筛选推荐商品


-- -------------------------------------------------------------------------------------------------
-- 有关的统计指标包含：访问量、活跃用户、新增用户、留存用户、流失用户、沉默用户、回流用户
--     （1）活跃用户：每日登录应用的用户
--     （2）新增用户：在当前日期第一次登录应用的用户
--     （3）留存用户：在当前日期登录应用的用户，并且在之前日期登录过应用
--     （4）流失用户：指定时间内没有登录应用的用户
--     （5）沉默用户：只有第一次登录应用的用户，之后没有登录过应用
--     （6）回流用户：在当前日期登录应用的用户，并且在之前的指定时间内没有登录过应用
--
-- 用户ID  登录日期
--   d     20220321
--   e     20220321
--   f     20220321
--   a     20220322
--   b     20220322
--   d     20220322
--   a     20220323
--   b     20220323
--   c     20220323
--   a     20220324
--   b     20220324
--   c     20220324
--   a     20220325
--   b     20220325
--   c     20220325
--   f     20220325
-- -------------------------------------------------------------------------------------------------
-- 全量的用户表：表示用户成为新增用户的日期
drop table if exists login_action;
create table if not exists login_action
(
    id         int         primary key comment '主键',
    uid        varchar(2)  not null    comment '用户 ID',
    login_date int         not null    comment '登录日期'
) engine = InnoDB character set = 'utf8mb4' comment '用户登录日期';

insert ignore into login_action (id, uid, login_date)
values (101, 'd', 20220321),
       (102, 'e', 20220321),
       (103, 'f', 20220321),
       (104, 'a', 20220322),
       (105, 'b', 20220322),
       (106, 'd', 20220322),
       (107, 'a', 20220323),
       (108, 'b', 20220323),
       (109, 'c', 20220323),
       (110, 'a', 20220324),
       (111, 'b', 20220324),
       (112, 'c', 20220324),
       (113, 'a', 20220325),
       (114, 'b', 20220325),
       (115, 'c', 20220325),
       (116, 'f', 20220325);

drop table if exists user_add;
create table if not exists user_add
(
    id       int         primary key comment '主键',
    uid      varchar(2)  not null    comment '用户 ID',
    add_date int         not null    comment '登录日期'
) engine = InnoDB character set = 'utf8mb4' comment '用户登录日期';

insert into user_add (id, uid, add_date)
select id, uid, login_date
from login_action
where login_date = 20220321;

-- 新增用户：登录行为表与全量用户表进行关联，行为表中存在、用户表中不存在的记录表示这个日期的新增用户
select la.uid,
       la.login_date
from login_action la left join user_add ua
     on la.uid = ua.uid
where la.login_date = 20220322              -- 查询日期 20220322 的新增用户
and ua.uid is null;                         -- 查询在用户表中不存在的记录，即这个日期的新增用户

-- 留存用户：登录行为表与全量用户表进行关联，行为表中的登录日期与用户表中的登录日期之差为 1 天，表示 1 日的留存用户
select la.uid,
       la.login_date,
       ua.add_date
from login_action la join user_add ua
    on    la.uid = ua.uid
where     la.login_date = 20220324          -- 查询日期 20220324 的留存用户
      and ua.add_date   = (20220324 - 1)    -- 查询 1 日留存用户
union all                                   -- 合并 1 日、2 日留存用户
select la.uid,
       la.login_date,
       ua.add_date
from login_action la join user_add ua
    on  la.uid        = ua.uid
where   la.login_date = 20220324            -- 查询日期 20220324 的留存用户
    and ua.add_date   = (20220324 - 2);     -- 查询 2 日留存用户

-- 流失用户：每个用户的登录日期的最大值，与当前日期之差超过 2 日，表示流失用户
select uid,
       max(login_date) as last_login
from login_action
where login_date <= 20220325            -- 查询日期 20220325 的流失用户
group by uid
having max(login_date) < (20220325 - 2); -- 超过 2 日表示流失用户

-- 沉默用户：查询每个用户的登录日期的数量，只有一次登录操作，表示沉默用户
select uid,
       max(login_date) as once_login
from login_action
group by uid
having count(login_date) = 1;          -- 只有一次登录操作的用户表示沉默用户

-- 回流用户：日期 20220325 的活跃用户，如果在之前的日期为流失用户，则在日期 20220325 为回流用户
select la.uid,
       la.login_date,
       ua.last_login
from
(
    select uid,
           login_date
    from login_action
    where login_date = 20220325                  -- 查询 20220325 的活跃用户
) la join
(
    select uid,
           max(login_date) as last_login
    from login_action
    where login_date < 20220325                  -- 查询20220325之前的流失用户
    group by uid
    having max(login_date) < (20220325 - 2)
) ua on la.uid = ua.uid;
