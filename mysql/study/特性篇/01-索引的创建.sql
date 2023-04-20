--  01- 索引的创建

-- 第1种：create table

-- 隐式的方式创建索引。在声明有主键约束、唯一性约束、外键约束的字段上，会自动的添加相关的索引
create table `dept` (`dept_id` int primary key auto_increment, `dept_name` varchar(20));
create table `emp`
(
    `emp_id`   int primary key auto_increment,
    `emp_name` varchar(20) unique,
    `dept_id`  int,
    constraint `emp_dept_id_fk` foreign key (`dept_id`) references `dept` (`dept_id`)
);

-- 显式的方式创建：
-- ① 创建普通的索引
create table `book`
(
    `book_id`          int,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year,
    index `idx_bname` (`book_name`)                                  -- 声明索引
);

show create table `book`;                                            -- 通过命令查看索引
show index from `book`;
explain select * from `book` where `book_name` = 'mysql高级';         -- 性能分析工具：explain

-- ② 创建唯一索引
--  声明有唯一索引的字段，在添加数据时，要保证唯一性，但是可以添加null
create table `book1`
(
    `book_id`          int,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year,
    unique index `uk_idx_cmt` (`comment`)                             -- 声明索引
);

show index from `book1`;
insert into `book1`(`book_id`, `book_name`, `comment`) values (1, 'mysql高级', '适合有数据库开发经验的人员学习');
insert into `book1`(`book_id`, `book_name`, `comment`) values (2, 'mysql高级', null);
select * from `book1`;

-- ③ 主键索引
-- 通过定义主键约束的方式定义主键索引
create table `book2`
(
    `book_id`          int primary key,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year
);

show index from `book2`;
alter table `book2` drop primary key;                                -- 通过删除主键约束的方式删除主键索引

-- ④ 创建单列索引
create table `book3`
(
    `book_id`          int,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year,
    unique index `idx_bname` (`book_name`)                           -- 声明索引
);

show index from `book3`;

-- ⑤ 创建联合索引
create table `book4`
(
    `book_id`          int,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year,
    index `mul_bid_bname_info` (`book_id`, `book_name`, `info`)      -- 声明索引
);

show index from `book4`;

-- 分析
explain select * from `book4` where `book_id` = 1001 and `book_name` = 'mysql';
explain select * from `book4` where `book_name` = 'mysql';

-- ⑥ 创建全文索引
create table `test4`
(
    `id`   int      not null,
    `name` char(30) not null,
    `age`  int      not null,
    `info` varchar(255),
    fulltext index `futxt_idx_info` (`info`(50))
);

show index from `test4`;


-- 第2种：表已经创建成功
-- ① alter table ... add ...
create table `book5`
(
    `book_id`          int,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year
);

show index from `book5`;
alter table `book5` add index `idx_cmt` (`comment`);
alter table `book5` add unique `uk_idx_bname` (`book_name`);
alter table `book5` add index `mul_bid_bname_info` (`book_id`, `book_name`, `info`);

-- ② create index ... on ...
create table `book6`
(
    `book_id`          int,
    `book_name`        varchar(100),
    `authors`          varchar(100),
    `info`             varchar(100),
    `comment`          varchar(100),
    `year_publication` year
);

show index from `book6`;
create index `idx_cmt` on `book6` (`comment`);
create unique index `uk_idx_bname` on `book6` (`book_name`);
create index `mul_bid_bname_info` on `book6` (`book_id`, `book_name`, `info`);
