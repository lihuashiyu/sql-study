# 第04章_运算符课后练习

# 1.选择工资不在5000到12000的员工的姓名和工资
select last_name, salary from employees                        # where salary not between 5000 and 12000;
where salary < 5000 or salary > 12000;

# 2.选择在20或50号部门工作的员工姓名和部门号
select last_name, department_id from employees                 # where department_id in (20,50);
where department_id = 20 or department_id = 50;

# 3.选择公司中没有管理者的员工姓名及 job_id
select last_name, job_id, manager_id from employees where manager_id is null;
select last_name, job_id, manager_id from employees where manager_id <=> null;

# 4.选择公司中有奖金的员工姓名，工资和奖金级别
select last_name, salary, commission_pct from employees where commission_pct is not null;
select last_name, salary, commission_pct from employees where not commission_pct <=> null;


# 5.选择员工姓名的第三个字母是 a 的员工姓名
select last_name from employees where last_name like '__a%';


# 6.选择姓名中有字母 a 和 k 的员工姓名
select last_name from employees where last_name like '%a%k%' or last_name like '%k%a%';
# where last_name like '%a%' and last_name LIKE '%k%';

# 7.显示出表 employees 表中 first_name 以 'e'结尾的员工信息
select first_name, last_name from employees where first_name like '%e';
select first_name, last_name from employees where first_name regexp 'e$';
# 以 e 开头的写法：'^e'

# 8.显示出表 employees 部门编号在 80-100 之间的姓名、工种
select last_name, job_id from employees
# 方式1：推荐
where department_id between 80 and 100;
# 方式2：推荐，与方式1相同
# where department_id >= 80 and department_id <= 100;
# 方式3：仅适用于本题的方式。
# where department_id in (80, 90, 100);

select * from departments;

# 9.显示出表 employees 的 manager_id 是 100,101,110 的员工姓名、工资、管理者id
select last_name, salary, manager_id from employees where manager_id in (100, 101, 110);


