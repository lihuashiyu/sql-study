-- 04-索引的设计原则


-- 1.创建学生表和课程表
create table if not exists student_info
(
    id          int(11)     auto_increment,
    student_id  int         not null,
    name        varchar(20) default null,
    course_id   int         not null,
    class_id    int(11)     default null,
    create_time datetime    default current_timestamp on update current_timestamp,
    primary key (id)
) engine = INNODB auto_increment = 1 default charset = utf8;

create table if not exists course
(
    id          int(11)     not null auto_increment,
    course_id   int         not null,
    course_name varchar(40) default null,
    primary key (id)
) engine = INNODB auto_increment = 1 default charset = utf8;



select @@log_bin_trust_function_creators;
set global log_bin_trust_function_creators = 1;

-- 函数 1：创建随机产生字符串函数
delimiter //
    create function rand_string(n int) returns varchar(255) -- 该函数会返回一个字符串
    begin
        declare chars_str  varchar(100) default 'abcdefghijklmnopqrstuvwxyzABCDEFJHIJKLMNOPQRSTUVWXYZ';
        declare return_str varchar(255) default '';
        declare i          int          default 0;
        while i < n
            do
                set return_str = concat(return_str, substring(chars_str, floor(1 + rand() * 52), 1));
                set i = i + 1;
            end while;
        return return_str;
    end
// delimiter ;

-- 函数2：创建随机数函数
delimiter //
    create function rand_num(from_num int, to_num int) returns int(11)
    begin
        declare i int default 0;
        set i = floor(from_num + rand() * (to_num - from_num + 1));
        return i;
    end
// delimiter ;

--  存储过程 1：创建插入课程表存储过程
delimiter //
    create procedure insert_course(max_num int)
    begin
        declare i int default 0;
        set autocommit = 0;                                          -- 设置手动提交事务
        repeat                                                       -- 循环
            set i = i + 1;                                         -- 赋值
            insert into course (course_id, course_name) values (rand_num(10000, 10100), rand_string(6));
        until i = max_num end repeat;
        commit;                                                      -- 提交事务
    end
// delimiter ;

--  存储过程2：创建插入学生信息表存储过程
delimiter //
create procedure insert_stu(max_num int)
    begin
        declare i int default 0;
        set autocommit = 0;                                          -- 设置手动提交事务
        repeat                                                       -- 循环
            set i = i + 1;                                         -- 赋值
            insert into student_info (course_id, class_id, student_id, NAME)
            values
            (
                 rand_num(10000, 10100), rand_num(10000, 10200),
                 rand_num(1, 200000),    rand_string(6)
            );
        until i = max_num end repeat;
        commit;                                                      -- 提交事务
    end
// delimiter ;

call insert_course(100);                                           -- 调用存储过程
select count(*) from course;
call insert_stu(1000000);
select count(*) from student_info;


-- 2. 哪些情况适合创建索引：① 字段的数值有唯一性的限制；② 频繁作为 WHERE 查询条件的字段
show index from student_info;                                      -- 查看当前 student_info 表中的索引
select course_id, class_id, NAME, create_time, student_id
from student_info where student_id = 123110;                      -- student_id字段上没有索引的：276 ms
alter table student_info add index idx_sid (student_id);         -- 给 student_id 字段添加索引
select course_id, class_id, NAME, create_time, student_id
from student_info where student_id = 123110;                      -- student_id 字段上有索引的：43 ms

-- ③ 经常 group by 和 order by 的列
select student_id, count(*) as num from student_info group by student_id limit 100;   -- 41ms
drop index idx_sid on student_info;                               -- 删除 idx_sid 索引
select student_id, count(*) as num from student_info group by student_id limit 100;   -- 866 ms
show index from student_info;                                      -- 再测试：

-- 添加单列索引
alter table student_info add index idx_sid (student_id);
alter table student_info add index idx_cre_time (create_time);
select student_id, count(*) as num from student_info group by student_id order by create_time desc limit 100;

-- 修改 sql_mode
select @@sql_mode;
set @@sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
                   ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
alter table student_info add index idx_sid_cre_time (student_id, create_time desc);   -- 添加联合索引
select student_id, count(*) as numfrom student_info group by student_id order by create_time desc limit 100;
alter table student_info add index idx_cre_time_sid (create_time desc, student_id);   -- 再进一步：
drop index idx_sid_cre_time on student_info;
select student_id, count(*) as num from student_info group by student_id order by create_time desc limit 100;

-- ④ update、delete 的 where 条件列
show index from student_info;
update student_info set student_id = 10002 where name = '462eed7ac6e791292a79';    -- 0.633s
alter table student_info add index idx_name (name);            -- 添加索引
update student_info set student_id = 10001 where name = '462eed7ac6e791292a79';    -- 0.001s

--  ⑤ distinct 字段需要创建索引；⑥ 多表 join 连接操作时，创建索引注意事项
-- 首先，连接表的数量尽量不要超过 3 张，因为每增加一张表就相当于增加了一次嵌套的循环，
--     数量级增长会非常快，严重影响查询的效率。
-- 其次，对 where 条件创建索引，因为 where 才是对数据条件的过滤。如果在数据量非常大的情况下，
--     没有 where 条件过滤是非常可怕的。
-- 最后，对用于连接的字段创建索引，并且该字段在多张表中的类型必须一致。比如
--     course_id 在 student_info 表和 course 表中都为 int(11) 类型，而不能一个为 int 另一个为 varchar 类型。

select s.course_id, NAME, s.student_id, c.course_name
from student_info    s
    join course c on s.course_id = c.course_id
where NAME = '462eed7ac6e791292a79';                               -- 0.001s

drop index idx_name on student_info;

select s.course_id, NAME, s.student_id, c.course_name
from student_info    s
    join course c on s.course_id = c.course_id
where NAME = '462eed7ac6e791292a79';                               -- 0.227s

-- ⑦ 使用列的类型小的创建索引；⑧ 使用字符串前缀创建索引；
-- ⑨ 区分度高(散列性高)的列适合作为索引；⑩ 使用最频繁的列放到联合索引的左侧
select * from student_info where student_id = 10013 and course_id = 100;
-- 补充：在多个字段都要创建索引的情况下，联合索引优于单值索引

--  3. 哪些情况不适合创建索引：当数据重复度大，比如高于 10% 的时候，也不需要对这个字段使用索引
--      ① 在where中使用不到的字段，不要设置索引；
--      ② 数据量小的表最好不要使用索引；
--      ③ 有大量重复数据的列上不要建立索引；
--      ④ 避免对经常更新的表创建过多的索引
--      ⑤ 不建议用无序的值作为索引
--      ⑥ 删除不再使用或者很少使用的索引
--      ⑦ 不要定义冗余或重复的索引
