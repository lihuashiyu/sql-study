-- 03 - Mysql8.0 新特性


-- 1. 支持降序索引
create table ts1(a int,b int,index idx_a_b(a asc,b desc));
show create table ts1;

delimiter //
    create procedure ts_insert()
    begin
        declare i int default 1;
        while i < 800
        do
            insert into ts1 select rand()*80000,rand()*80000;
            set i = i + 1;
        end while;
        commit;
    end
// delimiter ;

call ts_insert();                                                    -- 调用
select count(*) from ts1;                                            -- 优化测试
explain select * from ts1 order by a,b desc limit 5;
explain select * from ts1 order by a desc,b desc limit 5;            -- 不推荐

-- 2. 隐藏索引
-- ① 创建表时，隐藏索引
create table book7
(
    book_id          int,
    book_name        varchar(100),
    authors          varchar(100),
    info             varchar(100),
    comment          varchar(100),
    year_publication year,
    index idx_cmt (comment) invisible                            -- 创建不可见的索引
);

show index from book7;
explain select * from book7 where comment = 'mysql....';

-- ② 创建表以后
alter table book7
add unique index uk_idx_bname(book_name) invisible;
create index idx_year_pub on book7(year_publication);
explain select * from book7 where year_publication = '2022';

-- 修改索引的可见性
alter table book7 alter index idx_year_pub invisible;                -- 可见--->不可见
alter table book7 alter index idx_cmt visible;                       -- 不可见 ---> 可见

-- 了解：使隐藏索引对查询优化器可见
select @@optimizer_switch \g;
set session optimizer_switch="use_invisible_indexes=on";
explain select * from book7 where year_publication = '2022';
