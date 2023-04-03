show tables ;

set mapreduce.map.java.opts='-Xmx4096m';
set mapreduce.map.java.opts='-Xms4096m';

drop table if exists student;
create table if not exists student
(
    id     int    comment '学号',
    name   string comment '姓名',
    age    int    comment '年龄',
    gender int    comment '性别：-1，未知；0，女；1：男',
    hight  float  comment '身高：厘米',
    wight  float  comment '体重：千克',
    email  string comment '邮箱',
    remark string comment '备注'
) comment '学生';

set hive.execution.engine=mr;
insert into student (id, name, age, gender, hight, wight, email, remark) values (1, '张三', 33, 1, 172.1, 48.9, 'zhangsan@qq.com', '学生');
set hive.execution.engine=spark;
insert into student (id, name, age, gender, hight, wight, email, remark) values (2, '李四', 23, 0, 165.1, 53.9, 'lisi@qq.com', '学生');
insert into student (id, name, age, gender, hight, wight, email, remark) values (3, '王五', 28, 1, 168.3, 52.7, 'wangwu@qq.com', '学生');

explain formatted select * from student s inner join student t on s.age = t.age;
select * from student o inner join student n on o.age = n.age where o.id = 4;
select * from student limit 4;

show tables;
select count(*) from course_pay;                                     -- 19991649(01:53)
select count(*) from course_shopping_cart;                           -- 29992457(02:04)
select count(*) from sale_course;                                    -- 10000(02:07)
select count(*) from sale_course_detail;                             -- 29992457(02:06)
select count(*) from student;                                        -- 2(00:01)
select count(*) from test_school;                                     -- 1000000(02:21)
select count(*) from test_student;                                   -- 1000001(02:20)

describe formatted course_shopping_cart;
explain formatted select * from course_shopping_cart;
select * from student limit 10;

truncate table student;
show create table student;

show tables ;

drop table if exists movie_tmp;
create temporary table if not exists movie_tmp
(
    movie_class int,
    movie_code  int,
    movie_name  string,
    movie_type  int,
    stage       int,
    url         string
) row format delimited fields terminated by '\t';

load data local inpath '/home/issac/下载/100W.txt' overwrite into table movie_tmp;

drop table if exists movie;
create table if not exists movie
(
    movie_class int,
    movie_code  int,
    movie_name  string,
    movie_type  int,
    stage       int,
    url         string
) row format delimited fields terminated by '\t'
    stored as parquet TBLPROPERTIES('parquet.block.size'='4194304');

insert into movie (movie_class, movie_code, movie_name, movie_type, stage, url)
select movie_class, movie_code, movie_name, movie_type, stage, url from movie_tmp;

select * from movie limit 10;
select movie_class, count(movie_class) as count from movie where movie_class >= 0 group by movie_class order by movie_class;

