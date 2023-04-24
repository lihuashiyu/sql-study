--  06-索引优化与查询优化

-- 1. 数据准备
create table if not exists class
(
    id        int(11)     not null auto_increment,
    classname varchar(30) default null,
    address   varchar(40) default null,
    monitor   int         null,
    primary key (id)
) engine = INNODB auto_increment = 1;

create table if not exists student
(
    id      int(11)     not null auto_increment,
    stuno   int         not null,
    name    varchar(20) default null,
    age     int(3)      default null,
    classid int(11)     default null,
    primary key (id)
    -- constraint fk_class_id foreign key (classid) references t_class (id)
) engine = INNODB auto_increment = 1;

set global log_bin_trust_function_creators = 1;

delimiter //                                                         -- 随机产生字符串
    create function rand_string(n int) returns varchar(255)
    begin
        declare chars_str  varchar(100) default 'abcdefghijklmnopqrstuvwxyzABCDEFJHIJKLMNOPQRSTUVWXYZ';
        declare return_str varchar(255) default '';
        declare i int default 0;
        while i < n
            do
                set return_str = concat(return_str, substring(chars_str, floor(1 + rand() * 52), 1));
                set i = i + 1;
            end while;
        return return_str;
    end //
delimiter ;

delimiter //                                                         -- 用于随机产生多少到多少的编号
    create function rand_num(from_num int, to_num int) returns int(11)
    begin
        declare i int default 0;
        set i = floor(from_num + rand() * (to_num - from_num + 1));
        return i;
    end
// delimiter ;

-- 创建往 stu 表中插入数据的存储过程
delimiter //
    create procedure insert_stu(start int, max_num int)
    begin
        declare i int default 0;
        set autocommit = 0;                                          -- 设置手动提交事务
        repeat                                                       -- 循环
            set i = i + 1;                                         -- 赋值
            insert into student (stuno, name, age, classid)
            values ((start + i), rand_string(6), rand_num(1, 50), rand_num(1, 1000));
        until i = max_num end repeat;
        commit;                                                      -- 提交事务
    end
// delimiter ;

-- 执行存储过程，往 class 表添加随机数据
delimiter //
    create procedure insert_class(max_num int)
    begin
        declare i int default 0;
        set autocommit = 0;
        repeat
            set i = i + 1;
            insert into class (classname, address, monitor)
            values (rand_string(8), rand_string(10), rand_num(1, 100000));
        until i = max_num end repeat;
        commit;
    end
// delimiter ;

call insert_class(10000);                                  -- 执行存储过程，往 class 表添加 1 万条数据
call insert_stu(100000, 500000);                      -- 执行存储过程，往 stu 表添加 50 万条数据
select count(*) from class;
select count(*) from student;

delimiter //
    create procedure proc_drop_index(dbname varchar(200), tablename varchar(200))
    begin
        declare done int default 0;
        declare ct int default 0;
        declare _index varchar(200) default '';
        declare _cur cursor for select index_name from information_schema.statistics
                      where table_schema = dbname and table_name = tablename and
                            seq_in_index = 1       and index_name <> 'PRIMARY';
        -- 每个游标必须使用不同的 declare continue handler for not found set done=1 来控制游标的结束
        declare continue handler for not found set done = 2;
        open _cur;                                                 -- 若没有数据返回，程序继续,并将变量 done 设为 2
            fetch _cur into _index;
            while _index <> ''
            do
                set @str = concat("drop index ", _index, " on ", tablename);
                prepare sql_str from @str;
                execute sql_str;
                deallocate prepare sql_str;
                set _index = '';
                fetch _cur into _index;
            end while;
        close _cur;
    end
// delimiter ;

-- 2. 索引失效案例
-- 1）全值匹配我最爱
explain select sql_no_cache * from student where age = 30;
explain select sql_no_cache * from student where age = 30 and classid = 4;
explain select sql_no_cache * from student where age = 30 and classid = 4 and name = 'abcd';
select sql_no_cache * from student where age = 30 and classid = 4 and name = 'abcd';

create index idx_age on student (age);
create index idx_age_classid on student (age, classid);
create index idx_age_classid_name on student (age, classid, name);

-- 2）最佳左前缀法则
explain select sql_no_cache * from student where student.age = 30 and student.name = 'abcd';
explain select sql_no_cache * from student where student.classid = 1 and student.name = 'abcd';
explain select sql_no_cache * from student where classid = 4 and student.age = 30 and student.name = 'abcd';

drop index idx_age on student;
drop index idx_age_classid on student;
explain select sql_no_cache * from student where student.age = 30 and student.name = 'abcd';

-- 3)主键插入顺序
-- 4)计算、函数、类型转换(自动或手动)导致索引失效
explain select sql_no_cache * from student where student.name like 'abc%';    -- 此语句能够使用上索引
explain select sql_no_cache * from student where left(student.name, 3) = 'abc';

create index idx_name on student (name);
create index idx_sno on student (stuno);
explain select sql_no_cache id, stuno, name from student where stuno + 1 = 900001;
explain select sql_no_cache id, stuno, name from student where stuno = 900000;
explain select id, stuno, name from student where substring(name, 1, 3) = 'abc';

-- 5)类型转换导致索引失效
explain select sql_no_cache * from student where name = 123;
explain select sql_no_cache * from student where name = '123';

-- 6)范围条件右边的列索引失效
show index from student;
call proc_drop_index('atguigudb2', 'student');

create index idx_age_classid_name on student (age, classid, name);
explain select sql_no_cache * from student where student.age = 30 and student.classid > 20 and student.name = 'abc';
explain select sql_no_cache * from student where student.age = 30 and student.name = 'abc' and student.classid > 20;
create index idx_age_name_cid on student (age, name, classid);

-- 7)不等于(!= 或者<>)索引失效
create index idx_name on student (name);
explain select sql_no_cache * from student where student.name <> 'abc';
explain select sql_no_cache * from student where student.name != 'abc';

-- 8）is null 可以使用索引，is not null 无法使用索引
explain select sql_no_cache * from student where age is null;
explain select sql_no_cache * from student where age is not null;

-- 9)like 以通配符 % 开头索引失效
explain select sql_no_cache * from student where name like 'ab%';
explain select sql_no_cache * from student where name like '%ab%';

-- 10)or 前后存在非索引的列，索引失效
show index from student;
call proc_drop_index('atguigudb2', 'student');
create index idx_age on student (age);
explain select sql_no_cache * from student where age = 10 or classid = 100;
create index idx_cid on student (classid);

--  11)数据库和表的字符集统一使用 utf8mb4

-- 3. 关联查询优化

--  情况1：左外连接
create table if not exists type                                    -- 分类
(
    id int(10)   unsigned not null auto_increment,
    card int(10) unsigned not null,
    primary key (id)
);

create table if not exists book                                    -- 图书
(
    bookid int(10) unsigned not null auto_increment,
    card int(10)   unsigned not null,
    primary key(bookid)
);

-- 向分类表中添加 20 条记录
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));

-- 向图书表中添加 20 条记录
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));
insert into book(card) values (floor(1 + (rand() * 20)));

explain select sql_no_cache * from type left join book on type.card = book.card;
create index y on book (card);                                 -- 添加索引
explain select sql_no_cache * from type left join book on type.card = book.card;

create index x on type (card);
explain select sql_no_cache * from type left join book on type.card = book.card;

drop index y on book;
explain select sql_no_cache * from type left join book on type.card = book.card;

--  情况2：内连接
drop index x on type;
explain select sql_no_cache * from type inner join book on type.card = book.card;

create index y on book (card);                                 -- 添加索引
explain select sql_no_cache * from type inner join book on type.card = book.card;
create index x on type (card);
-- 结论：对于内连接来说，查询优化器可以决定谁作为驱动表，谁作为被驱动表出现的

explain select sql_no_cache * from type inner join book on type.card = book.card;
drop index y on book;                                            -- 删除索引
-- 结论：对于内连接来讲，如果表的连接条件中只能有一个字段有索引，则有索引的字段所在的表会被作为被驱动表出现。

explain select sql_no_cache * from type inner join book on type.card = book.card;
create index y on book (card);
explain select sql_no_cache * from type inner join book on type.card = book.card;

-- 向 type 表中添加数据（20 条数据）
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));
insert into type(card) values (floor(1 + (rand() * 20)));

-- 结论：对于内连接来说，在两个表的连接条件都存在索引的情况下，会选择小表作为驱动表。“小表驱动大表”
explain select sql_no_cache * from type inner join book on type.card = book.card;

-- join 的底层原理
create table if not exists t2
(
    id int(11) not null,
    a  int(11) default null,
    b  int(11) default null,
    primary key (id),
    index a (a)
) engine = INNODB;

delimiter //
    create procedure idata()
    begin
        declare i int;
        set i = 1;
        while(i <= 1000)
        do
            insert into t2 values (i, i, i);
            set i = i + 1;
        end while;
    end
// delimiter ;

call idata();

-- 创建 t1 表并复制 t1 表中前 100 条数据
create table if not exists t1 as select * from t2 where id <= 100;
select count(*) from t1;                                           -- 测试表数据
select count(*) from t2;
show index from t2;                                                -- 查看索引
show index from t1;

explain select * from t1 straight_join t2 on (t1.a = t2.a);
explain select * from t1 straight_join t2 on (t1.a = t2.b);

-- 4. 子查询的优化
create index idx_monitor on class (monitor);                   -- 创建班级表中班长的索引

-- 查询班长的信息
explain select * from student stu1 where stu1.stuno in
(
    select monitor from class c where monitor is not null
);

explain select stu1.* from student stu1
    join class c on stu1.stuno = c.monitor where c.monitor is not null;

-- 查询不为班长的学生信息
explain select sql_no_cache a.* from student a where a.stuno not in
(select monitor from class b where monitor is not null);
explain select sql_no_cache a.* from student a left
    outer join class b on a.stuno = b.monitor where b.monitor is null;

-- 5. 排序优化
-- 删除 student 和 class 表中的非主键索引
call proc_drop_index('atguigudb2', 'student');
call proc_drop_index('atguigudb2', 'class');
show index from student;
show index from class;

-- 过程一：
explain select sql_no_cache * from student order by age, classid;
explain select sql_no_cache * from student order by age, classid limit 10;

-- 过程二：order by 时不limit，索引失效
create index idx_age_classid_name on student (age, classid, name);   -- 创建索引
explain select sql_no_cache * from student order by age, classid;      -- 不限制，索引失效
-- explain  select sql_no_cache age,classid,name,id from student order by age,classid;

-- 增加 limit 过滤条件，使用上索引了
explain select sql_no_cache * from student order by age, classid limit 10;

-- 过程三：order by 时顺序错误，索引失效
-- 创建索引 age，classid，stuno
create index idx_age_classid_stuno on student (age, classid, stuno);

-- 以下哪些索引失效?
explain select * from student order by classid limit 10;
explain select * from student order by classid, name limit 10;
explain select * from student order by age, classid, stuno limit 10;
explain select * from student order by age, classid limit 10;
explain select * from student order by age limit 10;

-- 过程四：order by 时规则不一致, 索引失效 （顺序错，不索引；方向反，不索引）
explain select * from student order by age desc, classid asc limit 10;
explain select * from student order by classid desc, name desc limit 10;
explain select * from student order by age asc, classid desc limit 10;
explain select * from student order by age desc, classid desc limit 10;

-- 过程五：无过滤，不索引
explain select * from student where age = 45 order by classid;
explain select * from student where age = 45 order by classid, name;
explain select * from student where classid = 45 order by age;
explain select * from student where classid = 45 order by age limit 10;
create index idx_cid on student (classid);
explain select * from student where classid = 45 order by age;

-- 实战：测试 filesort 和 index 排序
call proc_drop_index('atguigudb2', 'student');
explain select sql_no_cache * from student where age = 30 and stuno < 101000 order by name;

-- 方案一: 为了去掉 filesort 我们可以把索引建成
create index idx_age_name on student (age, name);
explain select sql_no_cache * from student where age = 30 and stuno < 101000 order by name;

-- 方案二：
create index idx_age_stuno_name on student (age, stuno, name);
explain select sql_no_cache * from student where age = 30 and stuno < 101000 order by name;
drop index idx_age_stuno_name on student;
create index idx_age_stuno on student (age, stuno);

-- 6. 覆盖索引：删除之前的索引
-- 举例1：
drop index idx_age_stuno on student;
create index idx_age_name on student (age, name);
explain select * from student where age <> 20;
explain select age, name from student where age <> 20;

-- 举例2：
explain select * from student where name like '%abc';
explain select id, age from student where name like '%abc';
select crc32('hello') from dual;

-- 7. 索引条件下推 （ICP）
explain select * from s1 where key1 > 'z' and key1 like '%a';

select uuid() from dual;
set @uuid = uuid();
select @uuid, uuid_to_bin(@uuid), uuid_to_bin(@uuid, true);
