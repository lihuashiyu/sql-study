# 第08章_聚合函数的课后练习

# 1.where 子句可否使用组函数进行过滤?  No!

# 2. 查询公司员工工资的最大值，最小值，平均值，总和
select max(`salary`) as `max_sal`, min(`salary`) as `mim_sal`, avg(`salary`) as `avg_sal`, sum(`salary`) as `sum_sal` from `employees`;

# 3. 查询各 job_id 的员工工资的最大值，最小值，平均值，总和
select `job_id`, max(`salary`), min(`salary`), avg(`salary`), sum(`salary`)  from `employees` group by `job_id`;

# 4. 选择具有各个 job_id 的员工人数
select `job_id`, count(*) from `employees` group by `job_id`;

# 5. 查询员工最高工资和最低工资的差距（difference）
select max(`salary`) - min(`salary`) "difference" from `employees`;

# 6. 查询各个管理者手下员工的最低工资，其中最低工资不能低于6000，没有管理者的员工不计算在内
select `manager_id`, min(`salary`)
from `employees`
where `manager_id` is not null
group by `manager_id`
having min(`salary`) >= 6000;

# 7. 查询所有部门的名字，location_id，员工数量和平均工资，并按平均工资降序
select `d`.`department_name`, `d`.`location_id`, count(`employee_id`), avg(`salary`)
from `departments` `d` left join `employees` `e` on `d`.`department_id` = `e`.`department_id`
group by `department_name`, `location_id`;

# 8. 查询每个工种、每个部门的部门名、工种名和最低工资
select `d`.`department_name`, `e`.`job_id`, min(`salary`)
from `departments` `d` left join `employees` `e` on `d`.`department_id` = `e`.`department_id`
group by `department_name`, `job_id`
