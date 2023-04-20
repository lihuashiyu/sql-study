# 第 14 章_视图(View)

# 1. 视图的理解
/*
    ① 视图，可以看做是一个虚拟表，本身是不存储数据的,视图的本质，就可以看做是存储起来的SELECT语句
    ② 视图中SELECT语句中涉及到的表，称为基表
    ③ 针对视图做DML操作，会影响到对应的基表中的数据。反之亦然。
    ④ 视图本身的删除，不会导致基表中数据的删除。
    ⑤ 视图的应用场景：针对于小型项目，不推荐使用视图。针对于大型项目，可以考虑使用视图。
    ⑥ 视图的优点：简化查询; 控制数据的访问
*/

# 2. 如何创建视图
# 准备工作
create database `dbtest14`;
use `dbtest14`;

create table `emps` as select * from `atguigudb`.`employees`;
create table `depts` as select * from `atguigudb`.`departments`;

select * from `emps`;
select * from `depts`;

desc `emps`;
desc `atguigudb`.`employees`;

# 2.1 针对于单表
# 情况 1：视图中的字段与基表的字段有对应关系
create view `vu_emp1` as select `employee_id`, `last_name`, `salary` from `emps`;
select * from `vu_emp1`;

# 确定视图中字段名的方式1：
create view `vu_emp2` as
    select `employee_id` `emp_id`, `last_name` `lname`, `salary`     # 查询语句中字段的别名会作为视图中字段的名称出现
    from `emps`
    where `salary` > 8000;

# 确定视图中字段名的方式2：
create view `vu_emp3`(`emp_id`, `NAME`, `monthly_sal`)               # 小括号内字段个数与 select 中字段个数相同
as
    select `employee_id`, `last_name`, `salary`
    from `emps`
    where `salary` > 8000;

select * from `vu_emp3`;

# 情况 2：视图中的字段在基表中可能没有对应的字段
create view `vu_emp_sal` as
    select `department_id`, avg(`salary`) `avg_sal`
    from `emps`
    where `department_id` is not null
    group by `department_id`;

select * from `vu_emp_sal`;

# 2.2 针对于多表
create view `vu_emp_dept` as
    select `e`.`employee_id`, `e`.`department_id`, `d`.`department_name`
    from `emps`           `e`
             join `depts` `d` on `e`.`department_id` = `d`.`department_id`;

select * from `vu_emp_dept`;

# 利用视图对数据进行格式化
create view `vu_emp_dept1` as
    select concat(`e`.`last_name`, '(', `d`.`department_name`, ')') `emp_info`
    from `emps`           `e`
             join `depts` `d` on `e`.`department_id` = `d`.`department_id`;

select * from `vu_emp_dept1`;

# 2.3 基于视图创建视图
create view `vu_emp4` as select `employee_id`, `last_name` from `vu_emp1`;
select * from `vu_emp4`;

# 3. 查看视图
# 语法1：查看数据库的表对象、视图对象
show tables;

# 语法2：查看视图的结构
describe `vu_emp1`;

# 语法3：查看视图的属性信息
show table status like 'vu_emp1';

# 语法4：查看视图的详细定义信息
show create view `vu_emp1`;

# 4."更新"视图中的数据
# 4.1 一般情况，可以更新视图的数据
select * from `vu_emp1`;
select `employee_id`, `last_name`, `salary` from `emps`;

# 更新视图的数据，会导致基表中数据的修改
update `vu_emp1` set `salary` = 20000 where `employee_id` = 101;

# 同理，更新表中的数据，也会导致视图中的数据的修改
update `emps` set `salary` = 10000 where `employee_id` = 101;

# 删除视图中的数据，也会导致表中的数据的删除
delete from `vu_emp1` where `employee_id` = 101;
select `employee_id`, `last_name`, `salary` from `emps` where `employee_id` = 101;

# 4.2 不能更新视图中的数据
select * from `vu_emp_sal`;
update `vu_emp_sal` set `avg_sal` = 5000 where `department_id` = 30; # 更新失败
delete from `vu_emp_sal` where `department_id` = 30;                # 删除失败

# 5. 修改视图
desc `vu_emp1`;

create or replace view `vu_emp1` as                                # 方式1
    select `employee_id`, `last_name`, `salary`, `email`
    from `emps`
    where `salary` > 7000;

# 方式2
alter view `vu_emp1` as select `employee_id`, `last_name`, `salary`, `email`, `hire_date` from `emps`;

# 6. 删除视图
show tables;
drop view `vu_emp4`;
drop view if exists `vu_emp2`,`vu_emp3`;
