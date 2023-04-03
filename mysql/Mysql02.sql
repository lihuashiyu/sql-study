-- -------------------------------------------------------------------------------------------------
-- rank()：函数为结果集的分区中的每一行分配一个排名，行的等级由一加上前面的等级数指定

-- rank() over
-- (
--     partition by <expression>[{,<expression>...}]
--     order by <expression> [asc|desc], [{,<expression>...}]
-- )
-- -------------------------------------------------------------------------------------------------

show tables;


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 统计出每门课都大于 80 的学生的姓名：
-- -------------------------------------------------------------------------------------------------
drop table if exists `student`;
create table if not exists `student`
(
    `id`       int         primary key comment '学号',
    `name`     varchar(32) not null    comment '姓名',
    `ke_cheng` varchar(32) not null    comment '课程',
    `fen_shu`  int         not null    comment '分数'
) engine = InnoDB character set = 'utf8mb4' comment '面试';

insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('101', '张三', '语文', 81);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('102', '张三', '数学', 75);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('103', '李四', '语文', 76);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('104', '李四', '数学', 90);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('105', '王五', '语文', 81);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('106', '王五', '数学', 99);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('107', '王五', '英语', 90);
insert ignore into student (`id`, `name`, `ke_cheng`, `fen_shu`) values ('108', '王五', '英语', 90);

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

select * from student;


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 聚合月为：季度
-- -------------------------------------------------------------------------------------------------
drop table if exists `sale`;
create table if not exists `sale`
(
    `id`     int           primary key comment '主键',
    `year`   int           not null    comment '年份',
    `month`  int           not null    comment '月份',
    `amount` decimal(2, 1) not null    comment '销售额'
) engine = InnoDB character set = 'utf8mb4' comment '面试';

insert ignore into sale (`id`, `year`, `month`, `amount`) values (101, 1991, 1, 1.1);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (102, 1991, 2, 1.2);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (103, 1991, 3, 1.3);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (104, 1991, 4, 1.4);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (105, 1992, 1, 2.1);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (106, 1992, 2, 2.2);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (107, 1992, 3, 2.3);
insert ignore into sale (`id`, `year`, `month`, `amount`) values (108, 1992, 4, 2.4);

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
-- select * into `table2` from 'table1' where 1 <> 1;                   -- Mysql
-- create table `table2` as select * from  'table1' where 1 <> 1;       -- Oracle


-- -------------------------------------------------------------------------------------------------
-- 要求使用 SQL 统计购入商品为两种或两种以上的购物人记录
-- -------------------------------------------------------------------------------------------------
drop table if exists `shop_info`;
create table if not exists `shop_info`
(
    `id`            int        primary key comment '主键',
    `shopper`       varchar(4) not null    comment '购物人',
    `product_info`  varchar(4) not null    comment '商品名称',
    `product_count` int        not null    comment '商品数量'
) engine = InnoDB character set = 'utf8mb4' comment '购物信息';

insert ignore into shop_info (`id`, `shopper`, `product_info`, `product_count`) values (101, 'A', '甲', 2);
insert ignore into shop_info (`id`, `shopper`, `product_info`, `product_count`) values (102, 'B', '乙', 4);
insert ignore into shop_info (`id`, `shopper`, `product_info`, `product_count`) values (103, 'C', '丙', 1);
insert ignore into shop_info (`id`, `shopper`, `product_info`, `product_count`) values (104, 'A', '丁', 2);
insert ignore into shop_info (`id`, `shopper`, `product_info`, `product_count`) values (105, 'B', '丙', 5);

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
drop table if exists `compete_info`;
create table if not exists `compete_info`
(
    `id`      int        primary key comment '主键',
    `date`    date       not null    comment '比赛日期',
    `result`  varchar(4) not null    comment '比赛结果'
) engine = InnoDB character set = 'utf8mb4' comment '比赛信息';

insert ignore into compete_info (`id`, `date`, `result`) values (101, '2005-05-19', 'win');
insert ignore into compete_info (`id`, `date`, `result`) values (102, '2005-05-19', 'lose');
insert ignore into compete_info (`id`, `date`, `result`) values (103, '2005-05-19', 'lose');
insert ignore into compete_info (`id`, `date`, `result`) values (104, '2005-05-19', 'lose');
insert ignore into compete_info (`id`, `date`, `result`) values (105, '2005-05-20', 'win');
insert ignore into compete_info (`id`, `date`, `result`) values (106, '2005-05-20', 'lose');
insert ignore into compete_info (`id`, `date`, `result`) values (107, '2005-05-20', 'lose');

-- 转换为如下形式
-- year        win_count    lose_count
-- 2005-05-19     2             2
-- 2005-05-19     1             2
select `date`,
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

