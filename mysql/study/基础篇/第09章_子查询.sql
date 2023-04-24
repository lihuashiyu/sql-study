# 第 09 章_子查询

# 1. 由一个具体的需求，引入子查询
# 需求：谁的工资比Abel的高？
# 方式 1：
select salary from employees where last_name = 'Abel';
select last_name, salary from employees where salary > 11000;

# 方式 2：自连接
select e2.last_name, e2.salary
from employees e1, employees e2
where e2.salary > e1.salary and e1.last_name = 'Abel';                       # 多表的连接条件

# 方式 3：子查询
select last_name, salary from employees
where salary > (select salary from employees where last_name = 'Abel');

# 2. 称谓的规范：外查询（或主查询）、内查询（或子查询）
/*
    子查询（内查询）在主查询之前一次执行完成，子查询的结果被主查询（外查询）使用 。
    注意事项
        子查询要包含在括号内
        将子查询放在比较条件的右侧
        单行操作符对应单行子查询，多行操作符对应多行子查询
*/

# 不推荐：
select last_name, salary from employees
where (select salary from employees where last_name = 'Abel') < salary;

/*
    3. 子查询的分类
    角度1：从内查询返回的结果的条目数：单行子查询  vs  多行子查询
    角度2：内查询是否被执行多次：      相关子查询  vs  不相关子查询

    比如：相关子查询的需求：查询工资大于本部门平均工资的员工信息
            不相关子查询的需求：查询工资大于本公司平均工资的员工信息

    子查询的编写技巧（或步骤）：① 从里往外写  ② 从外往里写
*/

# 4. 单行子查询
# 4.1 单行操作符： =  !=  <>  >   >=  <  <=
# 题目：查询工资大于 149 号员工工资的员工的信息
select employee_id, last_name, salary from employees
where salary > (select salary from employees where employee_id = 149);

# 题目：返回 job_id 与 141 号员工相同，salary 比 143 号员工多的员工姓名，job_id 和工资
select last_name, job_id, salary
from employees
where job_id = (select job_id from employees where employee_id = 141)
  and salary > (select salary from employees where employee_id = 143);

# 题目：返回公司工资最少的员工的 last_name, job_id 和 salary
select last_name, job_id, salary from employees where salary = (select min(salary) from employees);

# 题目：查询与 141 号员工的 manager_id 和 department_id 相同的其他员工的 employee_id，manager_id，department_id。
# 方式1：
select employee_id, manager_id, department_id
from employees
where manager_id = (select manager_id from employees where employee_id = 141)
  and department_id = (select department_id from employees where employee_id = 141)
  and employee_id <> 141;

# 方式2：了解
select employee_id, manager_id, department_id from employees
where (manager_id, department_id) =
      (select manager_id, department_id from employees where employee_id = 141)
  and employee_id <> 141;

# 题目：查询最低工资大于 110 号部门最低工资的部门 id 和其最低工资
select department_id, min(salary)
from employees
where department_id is not null
group by department_id
having min(salary) > (select min(salary) from employees where department_id = 110);

# 题目：显式员工的 employee_id, last_name 和 location，其中，若员工 department_id 与 location_id
#       为 1800 的 department_id 相同，则 location 为 'Canada'，其余则为 'USA'
select employee_id, last_name,
       case department_id
           when (select department_id from departments where location_id = 1800) then 'Canada'
           else 'USA'
       end "location"
from employees;

# 4.2 子查询中的空值问题
select last_name, job_id from employees
where job_id = (select job_id from employees where last_name = 'Haas');

# 4.3 非法使用子查询
# 错误：Subquery returns more than 1 row
select employee_id, last_name from employees
where salary = (select min(salary) from employees group by department_id);

# 5.多行子查询
# 5.1 多行子查询的操作符： in  any all some(同 any)

# 5.2 举例：
# in:
select employee_id, last_name from employees
where salary in (select min(salary) from employees group by department_id);

# any / all:
# 题目：返回其它 job_id 中比 job_id 为 'it_prog' 部门任一工资低的员工的员工号、姓名、job_id 以及 salary
select employee_id, last_name, job_id, salary from employees where job_id <> 'it_prog'
    and salary < any (select salary from employees where job_id = 'IT_PROG');

# 题目：返回其它 job_id 中比 job_id 为 'it_prog' 部门所有工资低的员工的员工号、姓名、job_id 以及salary
select employee_id, last_name, job_id, salary
from employees
where job_id <> 'IT_PROG'
  and salary < all (select salary from employees where job_id = 'IT_PROG');

# 题目：查询平均工资最低的部门 id
# MySQL 中聚合函数是不能嵌套使用的
# 方式1：
select department_id from employees group by department_id
having avg(salary) =
       (
           select min(avg_sal) from
           (
                select avg(salary) avg_sal from employees group by department_id
           ) t_dept_avg_sal
       );

# 方式2：
select department_id from employees group by department_id
having avg(salary) <= all (select avg(salary) avg_sal from employees group by department_id);

# 5.3 空值问题
select last_name from employees where employee_id not in (select manager_id from employees);

# 6. 相关子查询
# 6.1 查询员工中工资大于公司平均工资的员工的 last_name, salary 和其 department_id
select last_name, salary, department_id from employees where salary > (select avg(salary) from employees);

# 题目：查询员工中工资大于本部门平均工资的员工的last_name,salary和其department_id
# 方式1：使用相关子查询
select last_name, salary, department_id from employees e1
where salary > (select avg(salary) from employees e2 where department_id = e1.department_id);

# 方式2：在 from 中声明子查询
select e.last_name, e.salary, e.department_id
from employees e,
     (
         select department_id, avg(salary) avg_sal from employees group by department_id
     ) t_dept_avg_sal
where e.department_id = t_dept_avg_sal.department_id and e.salary > t_dept_avg_sal.avg_sal;

# 题目：查询员工的id, salary, 按照 department_name 排序
select employee_id, salary from employees e
order by
    (
        select department_name from departments d where e.department_id = d.department_id
    ) asc;

# 结论：在SELECT中，除了GROUP BY 和 LIMIT之外，其他位置都可以声明子查询！
/*
    SELECT ....,....,....(存在聚合函数)
    FROM ... (LEFT / RIGHT)JOIN ....ON 多表的连接条件
    (LEFT / RIGHT)JOIN ... ON ....
    WHERE 不包含聚合函数的过滤条件
    GROUP BY ...,....
    HAVING 包含聚合函数的过滤条件
    ORDER BY ....,...(ASC / DESC )
    LIMIT ...,....
*/

# 题目：若employees表中employee_id与job_history表中employee_id相同的数目不小于2，
# 输出这些相同id的员工的employee_id,last_name和其job_id

select * from job_history;

select employee_id, last_name, job_id from employees e
where 2 <= (select count(*) from job_history j where e.employee_id = j.employee_id)

# 6.2 exists 与 not exists关键字
# 题目：查询公司管理者的employee_id，last_name，job_id，department_id信息
# 方式1：自连接
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

# 题目：查询departments表中，不存在于employees表中的部门的department_id和department_name
# 方式1：
select d.department_id, d.department_name
from employees e
         right join departments d on e.department_id = d.department_id
where e.department_id is null;

# 方式2：
select department_id, department_name from departments d
where not exists(select * from employees e where d.department_id = e.department_id);

select count(*) from departments;
