# 第 06 章_多表查询的课后练习

# 1.显示所有员工的姓名，部门号和部门名称。
select e.last_name, e.department_id, d.department_name
from employees e
         left outer join departments d on e.department_id = d.department_id;


# 2.查询 90 号部门员工的 job_id 和 90 号部门的 location_id
select e.job_id, d.location_id
from employees e join departments d on e.department_id = d.department_id
where d.department_id = 90;

desc departments;


# 3.选择所有有奖金的员工的 last_name, department_name, location_id, city
select e.last_name, e.commission_pct, d.department_name, d.location_id, l.city
from employees e
         left join departments d on e.department_id = d.department_id
         left join locations l on d.location_id = l.location_id
where e.commission_pct is not null;                                        # 也应该是 35 条记录

select * from employees where commission_pct is not null;                  # 35条记录


# 4. 选择 city 在 Toronto 工作的员工的 last_name, job_id, department_id, department_name
select e.last_name, e.job_id, e.department_id, d.department_name
from employees e
         join departments d on e.department_id = d.department_id
         join locations l on d.location_id = l.location_id
where l.city = 'Toronto';

# SQL92 语法：
select e.last_name, e.job_id, e.department_id, d.department_name
from employees e, departments d, locations l
where e.department_id = d.department_id and d.location_id = l.location_id and l.city = 'Toronto';


# 5.查询员工所在的部门名称、部门地址、姓名、工作、工资，其中员工所在部门的部门名称为 'Executive'
select d.department_name, l.street_address, e.last_name, e.job_id, e.salary
from departments d
         left join employees e on e.department_id = d.department_id
         left join locations l on d.location_id = l.location_id
where d.department_name = 'Executive';

desc departments;
desc locations;


# 6.选择指定员工的姓名，员工号，以及他的管理者的姓名和员工号，结果类似于下面的格式
employees	emp                                                                # manager mgr
kochhar		101	king	100

select emp.last_name   as "employees",
       emp.employee_id as "emp#",
       mgr.last_name   as "manager",
       mgr.employee_id as "mgr#"
from employees as emp
         left join employees as mgr on emp.manager_id = mgr.employee_id;


# 7.查询哪些部门没有员工，本题也可以使用子查询：暂时不讲
select d.department_id
from departments as d
         left join employees as e on d.department_id = e.department_id
where e.department_id is null;


# 8. 查询哪个城市没有部门
select l.location_id, l.city
from locations l
         left join departments d on l.location_id = d.location_id
where d.location_id is null;
select department_id from departments where department_id in (1000, 1100, 1200, 1300, 1600);


# 9. 查询部门名为 Sales 或 IT 的员工信息
select e.employee_id, e.last_name, e.department_id
from employees e join departments d on e.department_id = d.department_id
where d.department_name in ('Sales', 'IT');
