# 第09章_子查询的课后练习


# 1.查询和 Zlotkey 相同部门的员工姓名和工资
select last_name, salary
from employees
where department_id in (select department_id from employees where last_name = 'Zlotkey');

# 2.查询工资比公司平均工资高的员工的员工号，姓名和工资
select employee_id, last_name, salary
from employees
where salary > (select avg(salary) from employees);

# 3.选择工资大于所有 job_id = 'SA_MAN' 的员工的工资的员工的 last_name, job_id, salary
select last_name, job_id, salary
from employees
where salary > all (select salary from employees where job_id = 'SA_MAN');

# 4.查询和姓名中包含字母 u 的员工在相同部门的员工的员工号和姓名
select employee_id, last_name
from employees
where department_id in (select distinct department_id from employees where last_name like '%u%');

# 5.查询在部门的 location_id 为 1700 的部门工作的员工的员工号
select employee_id
from employees
where department_id in (select department_id from departments where location_id = 1700);

# 6.查询管理者是 King 的员工姓名和工资
select last_name, salary, manager_id
from employees
where manager_id in (select employee_id from employees where last_name = 'King');

# 7.查询工资最低的员工信息: last_name, salary
select last_name, salary from employees where salary = (select min(salary) from employees);

# 8.查询平均工资最低的部门信息
# 方式1：
select *
from departments
where department_id =
    (
        select department_id from employees group by department_id having avg(salary) =
        (
            select min(avg_sal) from
            (
                select avg(salary) as avg_sal from employees group by department_id
            ) as t_dept_avg_sal
        )
    );

# 方式2：
select * from departments
where department_id =
    (
        select department_id from employees group by department_id having avg(salary) <= all
        (
            select avg(salary) from employees group by department_id
        )
    );

# 方式3： LIMIT
select *
from departments
where department_id =
    (
        select department_id from employees group by department_id having avg(salary) =
        (
            select avg(salary) as avg_sal from employees group by department_id order by avg_sal asc limit 1
        )
    );

# 方式4：
select d.*
from departments d,
     (
         select department_id, avg(salary) as avg_sal from employees
         group by department_id order by avg_sal asc limit 0, 1
    ) as t_dept_avg_sal
where d.department_id = t_dept_avg_sal.department_id;

# 9.查询平均工资最低的部门信息和该部门的平均工资（相关子查询）
# 方式1：
select d.*,
    (
        select avg(salary) from employees where department_id = d.department_id
    ) as avg_sal
from departments d
where department_id =
    (
        select department_id from employees group by department_id having avg(salary) =
        (
            select min(avg_sal) from
            (
                select avg(salary) as avg_sal from employees group by department_id
            ) as t_dept_avg_sal
        )
    );

# 方式2：
select d.*,
    (
        select avg(salary) from employees where department_id = d.department_id
    ) as avg_sal
from departments d
where department_id =
    (
        select department_id from employees group by department_id having avg(salary) <= all
        (
            select avg(salary) from employees group by department_id
        )
    );

# 方式3： LIMIT
select d.*, (select avg(salary) from employees where department_id = d.department_id) as avg_sal
from departments d
where department_id =
    (
        select department_id from employees group by department_id having avg(salary) =
        (
            select avg(salary) as avg_sal from employees group by department_id order by avg_sal asc limit 1
        )
    );

# 方式4：
select d.*,
    (
        select avg(salary) from employees where department_id = d.department_id
    ) as avg_sal
from departments d,
    (
        select department_id, avg(salary) as avg_sal from employees
        group by department_id order by avg_sal asc limit 0,1
    ) as t_dept_avg_sal
where d.department_id = t_dept_avg_sal.department_id;

# 10.查询平均工资最高的 job 信息
# 方式1：
select *
from jobs
where job_id =
    (
        select job_id from employees group by job_id having avg(salary) =
        (
            select max(avg_sal) from
            (
                select avg(salary) as avg_sal from employees group by job_id
            ) as t_job_avg_sal
        )
    );

# 方式2：
select *
from jobs
where job_id =
    (
        select job_id  from employees group by job_id having avg(salary) >= all
        (
            select avg(salary) from employees group by job_id
        )
    );

# 方式3：
select *
from jobs
where job_id =
    (
        select job_id from employees group by job_id having avg(salary) =
        (
            select avg(salary) as avg_sal from employees group by job_id order by avg_sal desc limit 0, 1
        )
    );

# 方式4：
select j.*
from jobs j,
    (
        select job_id, avg(salary) as avg_sal from employees group by job_id
        order by avg_sal desc limit 0,1
    ) as t_job_avg_sal
where j.job_id = t_job_avg_sal.job_id;

# 11.查询平均工资高于公司平均工资的部门有哪些?
select department_id
from employees
where department_id is not null
group by department_id
having avg(salary) > (select avg(salary) from employees);


#12.查询出公司中所有 manager 的详细信息
# 方式1：自连接  xxx worked for yyy
select distinct mgr.employee_id, mgr.last_name, mgr.job_id, mgr.department_id
from employees emp join employees mgr on emp.manager_id = mgr.employee_id;

# 方式2：子查询
select employee_id, last_name, job_id, department_id
from employees
where employee_id in (select distinct manager_id from employees);

# 方式3：使用 exists
select employee_id, last_name, job_id, department_id
from employees e1
where exists(select * from employees e2 where e1.employee_id = e2.manager_id);


# 13.各个部门中 最高工资中最低的那个部门的 最低工资是多少?
# 方式1：
select min(salary)
from employees
where department_id =
    (
        select department_id from employees group by department_id having max(salary) =
        (
            select min(max_sal) from
            (
                select max(salary) as max_sal from employees group by department_id
            ) as t_dept_max_sal
        )
    );

select * from employees where department_id = 10;

# 方式2：
select min(salary)
from employees
where department_id =
    (
        select department_id from employees group by department_id having max(salary) <= all
        (
            select max(salary) from employees group by department_id
        )
    );

# 方式3：
select min(salary)
from employees
where department_id =
    (
        select department_id from employees group by department_id having max(salary) =
        (
            select max(salary) as max_sal from employees group by department_id
            order by max_sal asc limit 0, 1
        )
    );

# 方式4：
select min(salary)
from employees e,
    (
        select department_id, max(salary) as max_sal from employees group by department_id
        order by max_sal asc limit 0,1
    ) as t_dept_max_sal
where e.department_id = t_dept_max_sal.department_id;

# 14.查询平均工资最高的部门的 manager 的详细信息: last_name, department_id, email, salary
# 方式1：
select last_name, department_id, email, salary
from employees
where employee_id = any
    (
        select distinct manager_id  from employees where department_id =
        (
            select department_id from employees group by department_id having avg(salary) =
            (
                select max(avg_sal) from
                (
                    select avg(salary) as avg_sal from employees group by department_id
                ) as t_dept_avg_sal
            )
        )
    );

# 方式2：
select last_name, department_id, email, salary
from employees
where employee_id = any
    (
        select distinct manager_id from employees where department_id =
        (
            select department_id from employees group by department_id having avg(salary) >= all
            (
                select avg(salary) as avg_sal from employees group by department_id
            )
        )
    );

# 方式3：
select last_name, department_id, email, salary
from employees
where employee_id in
    (
        select distinct manager_id from employees e,
        (
            select department_id, avg(salary) as avg_sal from employees group by department_id
            order by avg_sal desc limit 0,1
        ) as t_dept_avg_sal
        where e.department_id = t_dept_avg_sal.department_id
    );


# 15. 查询部门的部门号，其中不包括job_id是"ST_CLERK"的部门号
# 方式1：
select department_id
from departments
where department_id not in (select distinct department_id from employees where job_id = 'ST_CLERK');

# 方式2：
select department_id
from departments d
where not exists
    (select * from employees e where d.department_id = e.department_id and e.job_id = 'ST_CLERK');


#16. 选择所有没有管理者的员工的last_name
select last_name
from employees emp
where not exists(select * from employees mgr where emp.manager_id = mgr.employee_id);

# 17．查询员工号、姓名、雇用时间、工资，其中员工的管理者为 'De Haan'
# 方式1：
select employee_id, last_name, hire_date, salary
from employees
where manager_id in (select employee_id from employees where last_name = 'De Haan');

# 方式2：
select employee_id, last_name, hire_date, salary
from employees e1
where exists
    (
        select *
        from employees e2
        where e1.manager_id = e2.employee_id and e2.last_name = 'De Haan'
    );


# 18.查询各部门中工资比本部门平均工资高的员工的员工号, 姓名和工资（相关子查询）
# 方式1：使用相关子查询
select last_name, salary, department_id
from employees e1
where salary > (select avg(salary) from employees e2 where department_id = e1.department_id);

# 方式2：在FROM中声明子查询
select e.last_name, e.salary, e.department_id
from employees e,
    (
        select department_id, avg(salary) as avg_sal from employees group by department_id
    ) as t_dept_avg_sal
where e.department_id = t_dept_avg_sal.department_id and e.salary > t_dept_avg_sal.avg_sal;


# 19.查询每个部门下的部门人数大于 5 的部门名称（相关子查询）
select department_name
from departments d
where 5 < (select count(*) from employees e where d.department_id = e.department_id);


# 20.查询每个国家下的部门个数大于 2 的国家编号（相关子查询）
select * from locations;

select country_id from locations l
where 2 < (select count(*) from departments d where l.location_id = d.location_id);

/* 
    子查询的编写技巧（或步骤）：① 从里往外写  ② 从外往里写

    如何选择？
    ① 如果子查询相对较简单，建议从外往里写。一旦子查询结构较复杂，则建议从里往外写
    ② 如果是相关子查询的话，通常都是从外往里写。
*/