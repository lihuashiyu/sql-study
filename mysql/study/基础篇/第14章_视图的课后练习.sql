# 第 14 章_视图的课后练习

use `dbtest14`;

# 练习 1：
# 1. 使用表 emps 创建视图 employee_vu，
# 其中包括姓名（last_name），员工号（employee_id），部门号(department_id)
create or replace view `employee_vu`(`lname`, `emp_id`, `dept_id`) as
    select `last_name`, `employee_id`, `department_id` from `emps`;

# 2. 显示视图的结构
desc `employee_vu`;

# 3. 查询视图中的全部内容
select * from `employee_vu`;

# 4. 将视图中的数据限定在部门号是80的范围内
create or replace view `employee_vu`(`lname`, `emp_id`, `dept_id`) as
    select `last_name`, `employee_id`, `department_id`
    from `emps`
    where `department_id` = 80;

# 练习2：
create table `emps` as select * from `atguigudb`.`employees`;
desc `emps`;

# 1. 创建视图emp_v1,要求查询电话号码以‘011’开头的员工姓名和工资、邮箱
create or replace view `emp_v1` as
    select `last_name`, `salary`, `email`
    from `emps`
    where `phone_number` like '011%';


# 2. 要求将视图 emp_v1 修改为查询电话号码以‘011’开头的并且邮箱中包含 e 字符的员工姓名和邮箱、电话号码
create or replace view `emp_v1` as
    select `last_name`, `email`, `phone_number`, `salary`
    from `emps`
    where `phone_number` like '011%' and `email` like '%e%';

select * from `emp_v1`;

# 3. 向 emp_v1 插入一条记录，是否可以？
desc `emps`;

# 实测：失败了
insert into `emp_v1` values ('Tom', 'tom@126.com', '01012345');

# 4. 修改emp_v1中员工的工资，每人涨薪1000
select * from `emp_v1`;
update `emp_v1` set `salary` = `salary` + 1000;

# 5. 删除emp_v1中姓名为Olsen的员工
delete from `emp_v1` where `last_name` = 'Olsen';

# 6. 创建视图emp_v2，要求查询部门的最高工资高于 12000 的部门id和其最高工资
create or replace view `emp_v2`(`dept_id`, `max_sal`) as
    select `department_id`, max(`salary`)
    from `emps`
    group by `department_id`
    having max(`salary`) > 12000;
select * from `emp_v2`;

# 7. 向 emp_v2 中插入一条记录，是否可以？
不可以！

# 错误：The target table emp_v2 of the INSERT is not insertable-into
insert into `emp_v2`(`dept_id`, `max_sal`) values (4000, 20000);

# 8. 删除刚才的emp_v2 和 emp_v1
drop view if exists `emp_v1`,`emp_v2`;
show tables;
