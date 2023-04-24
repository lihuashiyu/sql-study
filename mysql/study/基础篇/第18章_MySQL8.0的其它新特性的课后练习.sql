# 第 18 章_mysql8.0 的其它新特性的课后练习


# 1. 创建students数据表，如下
create database test18_mysql8;
use test18_mysql8;

create table students
(
    id      int primary key auto_increment,
    student varchar(15),
    points  tinyint
);

#2. 向表中添加数据如下
insert into students(student,points)
values ('张三',89), ('李四',77), ('王五',88), ('赵六',90), ('孙七',90), ('周八',88);

select * from students;

# 3. 分别使用 rank()、dense_rank() 和 row_number() 函数对学生成绩降序排列情况进行显示
# 方式1：
select
    row_number() over (order by points desc) as "排序1",
    rank()       over (order by points desc) as "排序2",
    dense_rank() over (order by points desc) as "排序3",
    student, points
from students;

# 方式2：
select
    row_number() over w as "排序1",
    rank()       over w as "排序2",
    dense_rank() over w as "排序3",
    student, points
from students window w as (order by points desc);
