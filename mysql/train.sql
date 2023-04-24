# noinspection NonAsciiCharactersForFile

-- -------------------------------------------------------------------------------------------------
-- rank()：函数为结果集的分区中的每一行分配一个排名，行的等级由一加上前面的等级数指定

-- rank() over
-- (
--     partition by <expression>[{,<expression>...}]
--     order by <expression> [asc|desc], [{,<expression>...}]
-- )
-- -------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 统计出 每个用户 每月访问次数 和 累积访问次数，如下表所示：
-- 用户id	月份	 小计	累积
-- u01      2017-01  11     11
-- u01      2017-02  12     23
-- u02      2017-01  12     12
-- u03      2017-01  8      8
-- u04      2017-01  3      3
-- -------------------------------------------------------------------------------------------------
drop table if exists view_user;
create table if not exists view_user
(
    id          int                   primary key  comment '主键',
    user_id     varchar(32)           not null     comment '用户 ID',
    visit_date  varchar(32)           not null     comment '用户访问日期',
    visit_count int         default 0 not null     comment '用户访问次数'
) engine = InnoDB character set = 'utf8mb4' comment '面试';

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
select
       user_id                                                            as `用户 ID`,
       visit_month                                                        as `月份`,
       sum                                                                as '小计',
       sum(t1.sum) over (partition by t1.user_id order by t1.visit_month) as `累计`
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


-- -------------------------------------------------------------------------------------------------
-- 有 50W 个京东店铺，每个顾客访问任何一个店铺的任何一个商品时都会产生一条访问日志，
--     访问日志存储的表名为 visit，访客的用户 id 为 user_id，被访问的店铺名称为 shop，请统计：
-- -------------------------------------------------------------------------------------------------
drop table if exists jingdong_visit;
create table if not exists jingdong_visit
(
    id         int          primary key comment '主键',
    user_id    varchar(32)  not null    comment '用户 ID',
    shop       varchar(32)  not null    comment '店铺名称',
    visit_log  varchar(32)  not null    comment '访问日志'
) engine = InnoDB character set = 'utf8mb4'  comment '面试';

insert ignore into jingdong_visit (id, user_id, shop, visit_log)
values (101, 'u01', 'taobao',   '看'),
       (102, 'u02', 'jingdong', '看'),
       (103, 'u03', 'jingdong', '看'),
       (104, 'u04', 'taobao',   '看'),
       (105, 'u01', 'bra',      '看'),
       (106, 'u01', 'jingdong', '看'),
       (107, 'u02', 'bra',      '看'),
       (108, 'u01', 'sex',      '看'),
       (109, 'u01', 'jingdong', '看'),
       (110, 'u01', 'jingdong', '看'),
       (111, 'u01', 'sex',      '看'),
       (112, 'u02', 'taobao',   '看'),
       (113, 'u02', 'taobao',   '看'),
       (114, 'u03', 'sex',      '看'),
       (115, 'u03', 'jingdong', '看'),
       (116, 'u02', 'jingdong', '看'),
       (117, 'u01', 'bra',      '看'),
       (118, 'u05', 'sex',      '看'),
       (119, 'u03', 'bra',      '看'),
       (120, 'u01', 'sex',      '看');

-- 1）每个店铺的 UV（访客数）
select shop,
       count(user_id) as uv
from
(
    select shop,
           user_id
    from jingdong_visit
    group by shop, user_id
) as t group by t.shop;

-- 2）每个店铺访问次数 top3 的访客信息：输出店铺名称、访客 id、访问次数
select t2.shop as shop_name,
       t2.user_id,
       t2.visit_count
from
(
    select t1.shop,
           t1.user_id,
           t1.visit_count,
           rank() over (partition by t1.shop order by t1.visit_count) as rk
    from
    (   
        select shop,
               user_id,
               count(user_id) as visit_count
        from jingdong_visit
        group by shop, user_id
    ) as t1
) as t2 where t2.rk <= 3;


-- -------------------------------------------------------------------------------------------------
-- 已知一个表 stg_order，有如下字段：user_id，visit_date，order_id，amount，请给出 sql 进行统计：
--     数据样例：10029028，2017-01-01，1000003251，33.57
-- -------------------------------------------------------------------------------------------------
drop table if exists stg_order;
create table if not exists stg_order
(
    id          int            primary key                                 comment '主键',
    user_id     varchar(4)     not null                                    comment '用户编号',
    visit_date  datetime       not null     default now() on update now()  comment '用户访问日期',
    order_id    int            not null                                    comment '订单编号',
    amount      decimal(12, 2) not null      default 0.00                  comment '成交金额'
) engine = InnoDB character set = 'utf8mb4' comment '订单表';

insert ignore into stg_order (id, user_id, visit_date, order_id, amount)
values (101, 'u01', '2017-01-01 12:01:09', 201, '49.99'),
       (102, 'u01', '2017-01-01 21:34:56', 202, '72.99'),
       (103, 'u02', '2017-01-12 23:21:44', 203, '18.66'),
       (104, 'u02', '2017-01-15 02:01:09', 204, '29.33'),
       (105, 'u03', '2017-01-11 17:01:09', 205, '99.89'),
       (106, 'u03', '2017-01-31 12:01:09', 206, '49.99'),
       (107, 'u04', '2017-01-25 03:16:18', 207, '19.99'),
       (108, 'u03', '2017-11-01 05:11:09', 208, '49.99'),
       (109, 'u03', '2017-11-13 13:51:09', 209, '19.99'),
       (110, 'u06', '2017-11-21 02:31:09', 210, '28.99'),
       (111, 'u04', '2017-11-27 12:41:09', 211, '46.99'),
       (112, 'u05', '2017-11-24 09:01:09', 212, '32.99');

-- 1）给出 2017 年每个月的订单数、用户数、总成交金额
select t.visit_month,
       count(t.user_id)    as user_count,
       sum(t.order_count)  as order_count,
       sum(t.total_amount) as total_amount
from
(
    select from_unixtime(unix_timestamp(visit_date), '%Y-%m') as visit_month,
           user_id,
           count(order_id) as 'order_count',
           sum(amount)     as 'total_amount'
    from stg_order
    group by visit_month, user_id
) as t group by t.visit_month;

--  2）给出 2017 年 11 月的新客数(指在 11 月才有第一笔订单)
select t.visit_month,
       t.user_id
from
(
    select user_id,
           from_unixtime(unix_timestamp(visit_date), '%Y-%m')     as visit_month,
           rank() over (partition by user_id order by visit_date) as rk
    from stg_order
 ) as t
where   t.rk          = 1
    and t.visit_month = '2017-11'
group by t.visit_month, t.user_id;


-- -------------------------------------------------------------------------------------------------
-- 有一个 5000 万的用户文件 user_table(user_id，user_name，user_age)，一个 2 亿记录的用户看电影的记录文件
--     movie_table(user_id，movie_url)，根据年龄段观看电影的次数进行排序
-- -------------------------------------------------------------------------------------------------
drop table if exists user_table;
create table if not exists user_table
(
    user_id    int          primary key  comment '用户编号',
    user_name  varchar(64)  not null     comment '用户名称',
    user_age   int          not null     comment '用户年龄'
) engine = InnoDB character set = 'utf8mb4' comment '用户文件';

insert ignore into user_table (user_id, user_name, user_age)
values (101, 'Jim',    15),
       (102, 'Kang',   24),
       (103, 'Issac',  2),
       (104, 'Tom',    32),
       (105, 'Gary',   17),
       (106, 'Mary',   22),
       (107, 'Lily',   24),
       (108, 'Yang',   25),
       (109, 'Jams',   25),
       (110, 'Beauty', 15);

drop table if exists movie_table;
create table if not exists movie_table
(
    id         int            primary key  comment '主键',
    user_id    varchar(32)    not null     comment '用户编号',
    movie_url  varchar(4096)  not null     comment '电影地址'
) engine = InnoDB character set = 'utf8mb4' comment '用户看电影的记录文件';

insert ignore into movie_table (id, user_id, movie_url)
values (10, 101, 'abc'),
       (11, 103, 'bcd'),
       (12, 101, 'cde'),
       (13, 104, 'abc'),
       (14, 107, 'bcd'),
       (15, 102, 'abc'),
       (16, 104, 'abe'),
       (17, 107, 'bce'),
       (18, 106, 'bce'),
       (19, 105, 'cde'),
       (20, 109, 'abd'),
       (21, 110, 'abc'),
       (22, 108, 'abc');

-- 根据年龄段观看电影的次数进行排序
select u.user_age         as age,
       m.movie_url        as url,
       count(m.movie_url) as count
from movie_table as m left join user_table  as u
     on u.user_id = m.user_id
group by u.user_age, m.movie_url
order by u.user_age;


-- -------------------------------------------------------------------------------------------------
-- 有日志如下，请写出代码求得所有用户和活跃用户的总数及平均年龄。（活跃用户指连续两天都有访问记录的用户）
--     日期   用户     年龄
--     11    test_1    23
--     11    test_2    19
--     11    test_3    39
--     11    test_1    23
--     11    test_3    39
--     11    test_1    23
--     12    test_2    19
--     13    test_1    23
-- -------------------------------------------------------------------------------------------------
drop table if exists active_user;
create table if not exists active_user
(
    id          int          primary key  comment '主键',
    visit_date  int          not null     comment '访问月份',
    user_id     varchar(32)  not null     comment '用户编号',
    user_age    int          not null     comment '用户年龄'
) engine = InnoDB character set = 'utf8mb4' comment '用户访问数据';

insert ignore into active_user (id, visit_date, user_id, user_age)
values (101, 11, 'test_1', 23),
       (102, 11, 'test_2', 19),
       (103, 11, 'test_3', 39),
       (104, 11, 'test_1', 23),
       (105, 11, 'test_3', 39),
       (106, 11, 'test_1', 23),
       (107, 12, 'test_2', 19),
       (108, 12, 'test_1', 23),
       (109, 13, 'test_1', 23),
       (110, 13, 'test_1', 23);

-- 【所有用户(users)】的总数及平均年龄 和 【活跃用户(active_user)】总数及平均年龄
with active as
(
    select count(t3.user) as `活跃用户数量`,
           avg(t3.age)    as '活跃用户平均年龄'
    from
    (
        select t2.user,
               t2.age,
               t2.diff,
               count(*) as count
        from
        (
            select t1.user,
                   t1.age,
                   t1.date,
                   t1.rk,
                   t1.date - t1.rk as diff
            from
            (
                select user_id                                                  as user,
                       visit_date                                               as date,
                       user_age                                                 as age,
                       rank() over ( partition by user_id order by visit_date ) as rk
                from active_user
                group by user_id, visit_date, user_age
            ) t1
        ) t2 group by t2.user, t2.age, t2.diff having count >= 2
    ) t3 group by t3.user, t3.age
),
users as
(
    select count(t.user_id) as 总用户数量,
           avg(t.user_age)  as 总用户平均年龄
    from
    (
        select user_id, user_age
        from active_user
        group by user_id, user_age
    ) as t
)
select * from active join users;


-- -------------------------------------------------------------------------------------------------
-- 写出在表 order_table 中，所有用户在今年 10 月份第一次购买商品的金额，
--     购买用户：user_id，订单金额：money，购买日期：payment_date(格式：2017-10-01)，订单id：order_id
-- -------------------------------------------------------------------------------------------------
drop table if exists order_table;
create table if not exists order_table
(
    id            int            primary key  comment '主键 ID',
    user_id       varchar(32)    not null     comment '购买用户编号',
    order_id      varchar(32)    not null     comment '订单编号',
    money         decimal(12, 2) not null     comment '购买日期',
    payment_date  date           not null     comment '订单金额'
) engine = InnoDB character set = 'utf8mb4' comment '订单表';

insert ignore into order_table (id, user_id, order_id, money, payment_date)
values (101, 'u01', 'abc', 23.9, '2017-10-01'),
       (102, 'u02', 'bcd', 29.9, '2017-04-21'),
       (103, 'u03', 'abd', 35.9, '2017-10-11'),
       (104, 'u02', 'abe', 85.9, '2017-01-04'),
       (105, 'u01', 'ace', 38.5, '2017-09-08'),
       (106, 'u02', 'ade', 67.6, '2017-07-11'),
       (107, 'u05', 'bce', 86.8, '2017-08-18'),
       (108, 'u02', 'bde', 83.3, '2017-12-22');

-- 所有用户在今年 10 月份第一次购买商品的金额
select user_id,
       money
from
(
    select t1.user_id,
           t1.money,
           t1.payment_date,
           rank() over (partition by t1.user_id order by t1.payment_date) as rk
    from
    (
        select user_id,
               money,
               payment_date
        from order_table
        where from_unixtime(unix_timestamp(payment_date), '%Y-%m') = '2017-10'
    ) as t1
) as t2 where t2.rk = 1;


-- -------------------------------------------------------------------------------------------------
-- 现有图书管理数据库的三个数据模型如下：
--     图书（数据表名：book）
--         序号	 字段名称    字段描述	字段类型
--         1     book_id    总编号      文本
--         2     sort       分类号      文本
--         3     book_name  书名        文本
--         4     writer     作者        文本
--         5     output     出版单位    文本
--         6     price      单价        数值（保留小数点后2位）

--     读者（数据表名：reader）
--         序号   字段名称     字段描述   字段类型
--         1      reader_id   借书证号   文本
--         2      company     单位       文本
--         3      name        姓名       文本
--         4      sex         性别       文本
--         5      grade       职称       文本
--         6      addr        地址       文本

--     借阅记录（数据表名：borrow_log）
--         序号   字段名称     字段描述   字段类型
--         1      reader_id   借书证号   文本
--         2      book_id     总编号     文本
--         3      borrow_ate  借书日期   日期
-- -------------------------------------------------------------------------------------------------
-- 1）创建图书管理库的图书、读者和借阅三个基本表的表结构
drop table if exists book;
create table if not exists book
(
    book_id   varchar(32)    primary key auto_increment comment '总编号',
    book_sort varchar(32)    not null                   comment '分类号',
    book_name varchar(64)    not null                   comment '书名',
    writer    varchar(64)    not null                   comment '作者',
    output    varchar(64)    not null                   comment '出版单位',
    price     decimal(14, 2) not null                   comment '单价'
) engine = InnoDB character set = 'utf8mb4' comment '图书';

drop table if exists reader;
create table if not exists reader
(
    reader_id varchar(32) primary key auto_increment comment '借书证号',
    company   varchar(32) not null                   comment '单位',
    name      varchar(64) not null                   comment '姓名：男，女，未知',
    sex       varchar(64) not null                   comment '性别',
    grade     varchar(64) not null                   comment '职称',
    address   varchar(2)  not null                   comment '地址'
) engine = InnoDB character set = 'utf8mb4' comment '读者';

drop table if exists borrow_log;
create table if not exists borrow_log
(
    reader_id   varchar(32) primary key auto_increment comment '总编号',
    book_id     varchar(32) not null                   comment '分类号',
    borrow_date varchar(64) not null                   comment '书名'
) engine = InnoDB character set = 'utf8mb4' comment '借阅记录';

-- 2）找出姓李的读者姓名（name）和所在单位（company）
select name, company from reader where name like '%李';

-- 3）查找“高等教育出版社”的所有图书名称（book_name）及单价（price），结果按单价降序排序
select book_name, price from book where output = '高等教育出版社' order by price desc ;

-- 4）查找价格介于 10 元和 20 元之间的图书种类(book_sort）出版单位（output）和单价（price），结果按出版单位（output）和单价（price）升序排序。
select book_sort, output, price from book where price >= 10 and price <= 20 order by output, price;

-- 5）查找所有借了书的读者的姓名（name）及所在单位（company）
select name, company from reader as r join borrow_log b on r.reader_id = b.reader_id group by name, company;

-- 6）求”科学出版社”图书的最高单价、最低单价、平均单价
select t.max_price           as max_price,
       t.min_price           as min_price,
       t.sum_price / t.count as avg_price
from
(
    select max(price)   as max_price,
           min(price)   as min_price,
           sum(price)   as sum_price,
           count(price) as count
    from book
    where output = '科学出版社'
) t;

select max(price) as max_price,
       min(price) as min_price,
       avg(price) as avg_price
from book;

-- 7）找出当前至少借阅了 2 本图书（大于等于 2 本）的读者姓名及其所在单位
select name,
       company
from
(
    select reader_id
    from borrow_log
    group by reader_id
    having count(reader_id) >= 2
) as b join reader as r
    on b.reader_id = r.reader_id;

-- 8）考虑到数据安全的需要，需定时将“借阅记录”中数据进行备份，使用一条 sql 语句，在备份用户 bak 下创建与“借阅记录”
--          表结构完全一致的数据表 borrow_log_bak，井且将“借阅记录”中现有数据全部复制到 borrow_log_bak 中
create table borrow_log_bak select * from borrow_log;

-- 9）现在需要将原 oracle 数据库中数据迁移至 hive 仓库，请写出“图书”在 hive 中的建表语句（hive 实现，提示：列分隔符 |；
--        数据表数据需要外部导入：分区分别以 month＿part、day＿part 命名）
drop table if exists book;
create table if not exists book
(
    book_id   string         comment '总编号',
    book_sort string         comment '分类号',
    book_name string         comment '书名',
    writer    string         comment '作者',
    output    string         comment '出版单位',
    price     decimal(14, 2) comment '单价'
) row_format delimited fields terminated by '|' partitioned by (month_part, day_part) comment '图书';

-- 10）hive 中有表 a，现在需要将表 a 的月分区　201505　中　user＿id 为 20000 的 user＿dinner 字段更新为 bonc8920，
-- 其他用户 user＿dinner 字段数据不变，请列出更新的方法步骤
create table if not exists tmp_a as select * from a where user_id <> 20000 and month_part = 201505;
insert into table tmp_a partition(month_part = '201505') values (20000, '其他字段', 'bonc8920');
insert into table a     partition(month_part = '201505') select * from tmp_a where month_part = 201505;


-- -------------------------------------------------------------------------------------------------
-- 有一个线上服务器(server)访问日志格式如下（用 sql 答题）
-- 时间                      接口               ip 地址
-- 2016-11-09 11：22：05    /api/user/login     110.23.5.33
-- 2016-11-09 11：23：10    /api/user/detail    57.3.2.16
-- .....                    .....               .....
-- 2016-11-09 23：59：40    /api/user/login     200.6.5.166
-- 求 11 月 9 号下午 14 点（14-15 点），访问 api/user/login 接口的 top10 的 ip 地址
-- -------------------------------------------------------------------------------------------------
drop table if exists server_log;
create table if not exists server_log
(
    log_id      int          primary key  comment '主键',
    log_time    datetime     not null     comment '日志记录时间',
    interface   varchar(16)  not null     comment '访问接口',
    ip_address  varchar(16)  not null     comment '访问者 IP 地址'
) engine = InnoDB character set = 'utf8mb4' comment '线上服务器访问日志';

insert ignore into server_log (log_id, log_time, interface, ip_address)
values (101, '2016-11-09 14:22:05', '/api/user/login',  '200.6.5.166'),
       (102, '2016-11-09 14:23:10', '/api/user/detail', '57.3.2.16'),
       (103, '2016-11-09 14:29:19', '/api/user/login',  '200.6.5.166'),
       (104, '2016-11-09 14:30:19', '/api/user/login',  '123.16.5.166'),
       (105, '2016-11-09 14:32:19', '/api/user/login',  '114.9.23.166'),
       (106, '2016-11-09 14:33:19', '/api/user/login',  '123.16.5.166'),
       (107, '2016-11-09 14:21:19', '/api/user/login',  '114.9.23.166'),
       (108, '2016-11-09 14:44:19', '/api/user/login',  '114.9.23.166'),
       (109, '2016-11-09 14:37:19', '/api/user/login',  '114.9.23.166'),
       (110, '2016-11-09 14:13:19', '/api/user/login',  '200.6.5.166');

-- 求 11 月 9 号下午 14 点（14-15 点），访问 api/user/login 接口的 top10 的 ip 地址
select ip_address,
       count(ip_address) as cnt
from server_log
where log_time >= '2016-11-09 14:00:00' and log_time <= '2016-11-09 15:00:00' and interface = '/api/user/login'
group by ip_address
order by cnt desc
limit 3;


-- -------------------------------------------------------------------------------------------------
-- 查询充值日志表 2015 年 7 月 9 号每个区组下充值额最大的账号，要求结果：
--       区组ID，账号，金额，充值时间
-- -------------------------------------------------------------------------------------------------
drop table if exists credit_log;
create table credit_log
(
    id          int(4)          primary key  comment '主键',
    dist_id     int(4)          not null     comment '区组 ID',
    account     varchar(16)     not null     comment '账号',
    money       decimal(11, 2)  not null     comment '充值金额',
    create_time datetime        not null     comment '订单时间'
) engine = innodb character set = 'utf8mb4' comment '充值日志表';

insert ignore into credit_log (id, dist_id, account, money, create_time)
values (10, 101, 'u01', '35.8', '2015-07-09 08:32:58'),
       (11, 103, 'u03', '19.8', '2015-07-09 08:32:58'),
       (12, 102, 'u04', '34.8', '2015-07-09 08:32:58'),
       (13, 100, 'u02', '45.8', '2015-07-09 08:32:58'),
       (14, 101, 'u03', '67.8', '2015-07-09 08:32:58'),
       (15, 102, 'u01', '24.8', '2015-07-09 08:32:58'),
       (16, 103, 'u02', '46.8', '2015-07-09 08:32:58'),
       (17, 102, 'u03', '47.8', '2015-07-09 08:32:58'),
       (18, 100, 'u01', '84.8', '2015-07-09 08:32:58'),
       (19, 102, 'u02', '32.8', '2015-07-09 08:32:58'),
       (20, 103, 'u03', '86.8', '2015-07-09 08:32:58');

-- 查询 2015 年 7 月 9 号每个区组下充值额最大的账号
select t.dist_id,
       t.account,
       t.money,
       t.create_time
from
(
    select dist_id,
           account,
           money,
           create_time,
           rank() over (partition by dist_id order by money) as rk
    from credit_log
    where date_format(create_time, '%Y-%m-%d') = '2015-07-09'
) as t where t.rk = 1;


-- -------------------------------------------------------------------------------------------------
-- 有一个账号表如下，请写出 SQL 语句，查询各自区组的 money 排名前十的账号（分组取前 10）
-- 重点：如何在 mysql 中实现类似 oracle 中 rank() over() 开窗函数的效果？
-- -------------------------------------------------------------------------------------------------
drop table if exists account;
create table if not exists account
(
    dist_id int(11)      comment '区组 ID',
    account varchar(100) comment '账号',
    gold    int(11)      comment '金币',
    primary key (dist_id, account)
) engine=InnoDB character set = 'utf8mb4';

select t.dist_id,
       t.account,
       t.gold,
       t.rk
from
(
    select dist_id,
           account,
           gold,
           rank() over (partition by dist_id order by gold) as rk
    from account
) as t where t.rk < 11;


-- -------------------------------------------------------------------------------------------------
-- 1）有三张表分别为会员表（member）销售表（sale）退货表（re_goods）
--    会员表有字段 member_id（会员 id，主键）credits（积分）；
--    销售表有字段 member_id（会员 id，外键）购买金额（mn_account）；
--    退货表中有字段 member_id（会员id，外键） 退货金额（rmn_account）；
-- 2）业务说明：
--     销售表中的销售记录可以是会员购买，也可是非会员购买。（即销售表中的 member_id 可以为空）
--     销售表中的一个会员可以有多条购买记录
--     退货表中的退货记录可以是会员，也可是非会员4、一个会员可以有一条或多条退货记录
-- 查询需求：分组查出销售表中所有会员购买金额，同时分组查出退货表中所有会员的退货金额，把会员 id
--          相同的 购买金额-退款金额 得到的结果更新到 会员表 中对应会员的积分字段（credits）
-- -------------------------------------------------------------------------------------------------
drop table if exists member;
create table if not exists member
(
    member_id int primary key comment '会员 ID',
    credits   int             comment '积分'
) engine=InnoDB character set = 'utf8mb4' comment = '会员表';

drop table if exists sale;
create table if not exists sale
(
    member_id   int            primary key comment '会员 ID',
    mn_account  decimal(10, 2)             comment '购买金额'
) engine=InnoDB character set = 'utf8mb4' comment = '销售表';

drop table if exists re_goods;
create table if not exists re_goods
(
    member_id    int            primary key comment '会员 ID',
    rmn_account  decimal(10, 2)             comment '退货金额'
) engine=InnoDB character set = 'utf8mb4' comment = '退货表';


with s as
(
    select member_id,
           sum(mn_account) as sale_account
    from sale
    where member_id is not null
    group by member_id
),
rg as
(
    select member_id,
           sum(rmn_account) as regood_account
    from re_goods
    where member_id is not null
    group by member_id
),
tmp as
(
    select s.member_id,
           s.sale_account,
           rg.regood_account,
           s.sale_account - rg.regood_account as credit
    from sale as s1 left join rg as r
        on s.member_id = r.member_id
)
update member as m
set m.credits = (m.credits + tmp.credit)
where m.member_id = tmp.member_id;


-- -------------------------------------------------------------------------------------------------
-- 现在有三个表 student（学生表）、course(课程表)、score（成绩单），结构如下：
drop table if exists student;
create table if not exists student
(
    student_id int         primary key comment '学号',
    name       varchar(16) not null    comment '姓名',
    age        int         not null    comment '年龄'
) engine=InnoDB character set = 'utf8mb4' comment '学生表';

insert ignore into student(student_id, name, age)
values (10, '张三', 21),
       (11, '李四', 18),
       (12, '王五', 22),
       (13, '赵六', 19);

drop table if exists course;
create table if not exists course
(
	course_id   int         primary key comment '课程号：10/11/12 格式',
	course_name varchar(16) not null    comment '课程名'
) engine=InnoDB character set = 'utf8mb4' comment '课程表';

insert ignore into course (course_id, course_name) values (11, '数学'), (12, '英语'), (13, '物理'), (14, '化学');

drop table if exists score;
Create table if not exists score
(
	id         int primary key comment '主键',
	student_id int not null    comment '学号',
	course_id  int not null    comment '课程号',
	score     int  not null    comment '成绩'
) engine=InnoDB character set = 'utf8mb4' comment '成绩单';

insert ignore into score (id, student_id, course_id, score)
values (101, 10, 11, 54),
       (102, 10, 12, 78),
       (103, 10, 13, 33),
       (104, 10, 14, 54),
       (105, 11, 11, 77),
       (106, 11, 12, 62),
       (107, 11, 13, 38),
       (108, 11, 14, 37),
       (109, 12, 11, 88),
       (110, 12, 12, 25),
       (111, 12, 13, 57),
       (112, 12, 14, 39),
       (113, 13, 11, 44),
       (113, 13, 12, 54),
       (113, 13, 13, 37),
       (114, 13, 14, 88);
-- delete from score where id = 114;

-- -------------------------------------------------------------------------------------------------
-- 1）请将本地文件（/home/users/test/20190301.csv）文件，加载到分区表 score 的 20190301 分区中，并覆盖之前的数据
-- load data local inpath '/home/users/test/20190301.csv' overwrite into table score partition(dt='2019-03-01');

-- 2）查出平均成绩大于 60 分的学生的姓名、年龄、平均成绩
select u.student_id,
       u.name,
       t.avg_score
from student u left join
(
    select student_id,
           avg(score) as avg_score
    from score s
    group by id
    having avg_score > 60
) t on t.student_id = u.student_id;

-- 3）查出没有 13 课程成绩的学生的姓名、年龄
select name,
       age
from student
where student_id not in
(
    select student_id
    from score
    where course_id = 13
    group by student_id
);

-- 4）查出有 10\11 这两门课程下，成绩排名前 3 的学生的姓名、年龄
select name,
       age
from student s
where s.student_id in
(
    select t.student_id
    from
    (
        select student_id
        from score
        where course_id in (10, 11)
        group by student_id, score
        order by score desc
        limit 3
    ) t
);

-- 5）创建新的表 score_20190317，并存入 score 表中 20190317 分区的数据
create table score_20190317 as select * from score where id = 20190317;

-- 6）如果上面的 score 表中，uid 存在数据倾斜，请进行优化，查出在 20190101-20190317 中，学生的姓名、年龄、课程、课程的平均成绩


-- 8）简单描述一下 lateral view 语法在 HQL 中的应用场景，并写一个 HQL 实例
# 一般用于 udtf 函数，可以实现一进多出的炸裂函数效果。
# 比如一个学生表为：
-- 学号    姓名    年龄    成绩（语文|数学|英语）
-- 001     张三    16        90，80，95
-- 学号    成绩
-- 001     90
-- 001     80
-- 001     95
select student_id,
       name,
       age,
       score
from student lateral view explode(scores) temp as score;


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 统计出每门课都大于 80 的学生的姓名：
-- -------------------------------------------------------------------------------------------------
drop table if exists student;
create table if not exists student
(
    id       int         primary key comment '学号',
    name     varchar(32) not null    comment '姓名',
    ke_cheng varchar(32) not null    comment '课程',
    fen_shu  int         not null    comment '分数'
) engine = InnoDB character set = 'utf8mb4' comment '面试';

insert ignore into student (id, name, ke_cheng, fen_shu)
values (101, '张三', '语文', 81),
       (102, '张三', '数学', 75),
       (103, '李四', '语文', 76),
       (104, '李四', '数学', 90),
       (105, '王五', '语文', 81),
       (106, '王五', '数学', 99),
       (107, '王五', '英语', 90),
       (108, '王五', '英语', 90);

-- 每门课都大于 80 的学生的姓名
select name, fen_shu from student where fen_shu > 80 group by name order by name;

-- 删除学号不同，其他丢相同的学生信息
delete from student
where id not in
(
    select t.id from
    (
        select min(id) as id
        from student
        group by name, ke_cheng, fen_shu
    ) t
);


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 聚合月为：季度
-- -------------------------------------------------------------------------------------------------
drop table if exists sale;
create table if not exists sale
(
    id     int           primary key comment '主键',
    year   int           not null    comment '年份',
    month  int           not null    comment '月份',
    amount decimal(2, 1) not null    comment '销售额'
) engine = InnoDB character set = 'utf8mb4' comment '面试';

insert ignore into sale (id, year, month, amount)
values (101, 1991, 1, 1.1),
       (102, 1991, 2, 1.2),
       (103, 1991, 3, 1.3),
       (104, 1991, 4, 1.4),
       (105, 1992, 1, 2.1),
       (106, 1992, 2, 2.2),
       (107, 1992, 3, 2.3),
       (108, 1992, 4, 2.4);

-- 转换形式如下：
-- year    m1    m2    m3    m4
-- 1991    1.1   1.2   1.3   1.4
-- 1992    2.1   2.2   2.3   2.4
select year,
       (select amount from sale m where m.year = s.year and m.month = 1) as m1,
       (select amount from sale m where m.year = s.year and m.month = 2) as m2,
       (select amount from sale m where m.year = s.year and m.month = 3) as m3,
       (select amount from sale m where m.year = s.year and m.month = 4) as m4
from sale s
group by year;


-- -------------------------------------------------------------------------------------------------
-- 只复制表，不复制数据
-- -------------------------------------------------------------------------------------------------
-- select * into table2 from 'table1' where 1 <> 1;                   -- Mysql
-- create table table2 as select * from  'table1' where 1 <> 1;       -- Oracle


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 统计购入商品为两种或两种以上的购物人记录
-- -------------------------------------------------------------------------------------------------
drop table if exists shop_info;
create table if not exists shop_info
(
    id            int        primary key comment '主键',
    shopper       varchar(4) not null    comment '购物人',
    product_info  varchar(4) not null    comment '商品名称',
    product_count int        not null    comment '商品数量'
) engine = InnoDB character set = 'utf8mb4' comment '购物信息';

insert ignore into shop_info (id, shopper, product_info, product_count)
values (101, 'A', '甲', 2),
       (102, 'B', '乙', 4),
       (103, 'C', '丙', 1),
       (104, 'A', '丁', 2),
       (105, 'B', '丙', 5);

-- 统计购入商品为两种或两种以上的购物人记录
select id,
       shopper,
       product_info,
       product_count
from shop_info
where shopper in
(
    select shopper
    from shop_info
    group by shopper
    having count(shopper) >= 2
);


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 转换表数据
-- -------------------------------------------------------------------------------------------------
drop table if exists compete_info;
create table if not exists compete_info
(
    id      int        primary key comment '主键',
    date    date       not null    comment '比赛日期',
    result  varchar(4) not null    comment '比赛结果'
) engine = InnoDB character set = 'utf8mb4' comment '比赛信息';

insert ignore into compete_info (id, date, result)
values (101, '2005-05-19', 'win'),
       (102, '2005-05-19', 'lose'),
       (103, '2005-05-19', 'lose'),
       (104, '2005-05-19', 'lose'),
       (105, '2005-05-20', 'win'),
       (106, '2005-05-20', 'lose'),
       (107, '2005-05-20', 'lose');

-- 转换为如下形式
-- year        win_count    lose_count
-- 2005-05-19     2             2
-- 2005-05-19     1             2
select date,
       sum(case when c.result = 'win'  then 1 else 0 end) as win_count,
       sum(case when c.result = 'lose' then 1 else 0 end) as lose_count
from compete_info c
group by c.date;

select c.date as date,
       sum(id) over (order by date rows between 1 preceding and 1 following) as sum
from compete_info as c;

select c.date as date,
       sum(c.id) over (order by c.id range between 10 preceding and 100 following) as s
       -- lag() over () as lag
from compete_info as c;
