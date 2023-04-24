-- 07-数据表的设计规范

-- 反范式化的举例：
create table if not exists student                                 -- 学生表
(
    stu_id      int primary key auto_increment,
    stu_name    varchar(25),
    create_time datetime
);

create table if not exists class_comment                           -- 课程评论表
(
    comment_id   int primary key auto_increment,
    class_id     int,
    comment_text varchar(35),
    comment_time datetime,
    stu_id       int
);

-- 创建向学生表中添加数据的存储过程
delimiter //
    create procedure batch_insert_student(in start int(10), in max_num int(10))
    begin
        declare i          int      default 0;
        declare date_start datetime default ('2017-01-01 00:00:00');
        declare date_temp  datetime;
        set date_temp = date_start;
        set autocommit = 0;
        repeat
            set i         = i + 1;
            set date_temp = date_add(date_temp, interval rand() * 60 second);
            insert into student(stu_id, stu_name, create_time)
                values ((start + i), concat('stu_', i), date_temp);
        until i = max_num end repeat;
        commit;
    end
// delimiter ;

-- 调用存储过程，学生 id 从 10001 开始，添加 1000000 数据
call batch_insert_student(10000, 1000000);

-- 创建向课程评论表中添加数据的存储过程
delimiter //
    create procedure batch_insert_class_comments(in start int(10), in max_num int(10))
    begin
        declare i            int          default 0;
        declare date_start   datetime     default ('2018-01-01 00:00:00');
        declare date_temp    datetime;
        declare comment_text varchar(25);
        declare stu_id int;
        set date_temp    = date_start;
        set autocommit    = 0;
        repeat
            set i            = i + 1;
            set date_temp    = date_add(date_temp, interval rand() * 60 second);
            set comment_text = substr(md5(rand()), 1, 20);
            set stu_id       = floor(rand() * 1000000);
            insert into class_comment(comment_id, class_id, comment_text, comment_time, stu_id)
            values ((start + i), 10001, comment_text, date_temp, stu_id);
        until i = max_num end repeat;
        commit;
    end
// delimiter ;

-- 添加数据的存储过程的调用，一共1000000条记录
call batch_insert_class_comments(10000, 1000000);
select count(*) from student;
select count(*) from class_comment;

-- 需求
select p.comment_text, p.comment_time, stu.stu_name
    from class_comment     as p
         left join student as stu on p.stu_id = stu.stu_id
where p.class_id = 10001 order by p.comment_id desc limit 10000;

-- -- -- -- -- 进行反范式化的设计-- -- -- -- -- --
create table if not exists class_comment1 as select * from class_comment;      -- 表的复制

-- 添加主键，保证 class_comment1 与 class_comment 的结构相同
alter table class_comment1 add primary key (comment_id);
show index from class_comment1;

alter table class_comment1 add stu_name varchar(25);             -- 向课程评论表中增加 stu_name 字段
update class_comment1 c set stu_name =
(
    select stu_name from student s where c.stu_id = s.stu_id
);

-- 查询同样的需求
select comment_text, comment_time, stu_name from class_comment1
where class_id = 10001 order by comment_id desc limit 10000;
