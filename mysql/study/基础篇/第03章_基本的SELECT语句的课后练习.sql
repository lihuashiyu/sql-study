#第03章_基本的SELECT语句的课后练习

# 1.查询员工12个月的工资总和，并起别名为ANNUAL SALARY
# 理解1：计算12月的基本工资
select `employee_id`, `last_name`, `salary` * 12 "annual salary" from `employees`;

# 理解2：计算12月的基本工资和奖金
select `employee_id`, `last_name`, `salary` * 12 * (1 + ifnull(`commission_pct`, 0)) "annual salary" from `employees`;

# 2.查询employees表中去除重复的job_id以后的数据
select distinct `job_id` from `employees`;

# 3.查询工资大于12000的员工姓名和工资
select `last_name`, `salary` from `employees` where `salary` > 12000;

# 4.查询员工号为176的员工的姓名和部门号
select `last_name`, `department_id` from `employees` where `employee_id` = 176;

# 5.显示表 departments 的结构，并查询其中的全部数据 
describe `departments`;

select * from `departments`;

