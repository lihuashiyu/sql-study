# 第 05 章_排序与分页的课后练习


# 1. 查询员工的姓名和部门号和年薪，按年薪降序，按姓名升序显示
select last_name, department_id, salary * 12 annual_salary from employees order by annual_salary desc, last_name asc;

# 2. 选择工资不在 8000 到 17000 的员工的姓名和工资，按工资降序，显示第 21 到 40 位置的数据
select last_name, salary from employees where salary not between 8000 and 17000 order by salary desc limit 20, 20;

# 3. 查询邮箱中包含 e 的员工信息，并先按邮箱的字节数降序，再按部门号升序
select employee_id, last_name, email, department_id from employees   # where email like '%e%'
where email regexp '[e]' order by length(email) desc, department_id;
