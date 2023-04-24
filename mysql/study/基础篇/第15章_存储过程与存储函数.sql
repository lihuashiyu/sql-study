#第 15 章_存储过程与存储函数

# 0.准备工作
create database dbtest15;
use dbtest15;

create table employees as select * from atguigudb.employees;
create table departments as select * from atguigudb.departments;

select * from employees;
select * from departments;

# 1. 创建存储过程
# 类型1：无参数无返回值
# 举例1：创建存储过程select_all_data()，查看 employees 表的所有数据
delimiter $
    create procedure select_all_data()
    begin
        select * from employees;
    end $
delimiter ;

call select_all_data();                                            # 存储过程的调用

# 举例2：创建存储过程avg_employee_salary()，返回所有员工的平均工资
delimiter //
    create procedure avg_employee_salary()
    begin
        select avg(salary) from employees;
    end //
delimiter ;

call avg_employee_salary();                                        # 调用

# 举例3：创建存储过程show_max_salary()，用来查看“emps”表的最高薪资值。
delimiter //
    create procedure show_max_salary()
    begin
        select max(salary) from employees;
    end //
delimiter ;

call show_max_salary();                                            # 调用

# 类型 2：带 out
# 举例 4：创建存储过程show_min_salary()，查看“emps”表的最低薪资值。并将最低薪资
# 通过 out 参数“ms”输出
desc employees;

delimiter //
    create procedure show_min_salary(out ms double)
    begin
        select min(salary) into ms from employees;
    end //
delimiter ;

call show_min_salary(@ms);                                    # 调用
select @ms;                                                        # 查看变量值

# 类型 3：带 IN
# 举例 5：创建存储过程show_someone_salary()，查看“emps”表的某个员工的薪资，
# 并用 IN 参数 empname 输入员工姓名。
delimiter //
    create procedure show_someone_salary(in empname varchar(20))
    begin
        select salary from employees where last_name = empname;
    end //
delimiter ;

call show_someone_salary('Abel');                                  # 调用方式 1
set @empname := 'Abel';                                                      # 调用方式2
call show_someone_salary(@empname);

select * from employees
where last_name = 'Abel';

# 类型4：带 in 和 out
# 举例6：创建存储过程 show_someone_salary2()，查看“emps”表的某个员工的薪资，
# 并用in参数 empname 输入员工姓名，用 out 参数 empsalary 输出员工薪资。

delimiter //
    create procedure show_someone_salary2(in empname varchar(20), out empsalary decimal(10, 2))
    begin
        select salary into empsalary from employees where last_name = empname;
    end //
delimiter ;

set @empname = 'Abel';                                             # 调用
call show_someone_salary2(@empname, @empsalary);

select @empsalary;

# 类型5：带 inout
# 举例7：创建存储过程show_mgr_name()，查询某个员工领导的姓名，并用inout参数“empname”输入员工姓名，
# 输出领导的姓名。
desc employees;

delimiter $
    create procedure show_mgr_name(inout empname varchar(25))
    begin
        select last_name  into empname from employees
        where employee_id =
            (
                select manager_id from employees where last_name = empname
            );
    end $
delimiter ;

set @empname := 'Abel';                                            # 调用
call show_mgr_name(@empname);
select @empname;

# 2.存储函数
# 举例1：创建存储函数，名称为email_by_name()，参数定义为空，
# 该函数查询 Abel 的 email，并返回，数据类型为字符串型。
delimiter //
    create function email_by_name() returns varchar(25) deterministic
        contains sql
        reads sql data
    begin
        return ( select email from employees where last_name = 'Abel' );
    end //
delimiter ;

select email_by_name();                                            # 调用

select email, last_name from employees where last_name = 'Abel';

# 举例2：创建存储函数，名称为 email_by_id()，参数传入 emp_id，该函数查询 emp_id 的 email，
# 并返回，数据类型为字符串型。
# 创建函数前执行此语句，保证函数的创建会成功
set global log_bin_trust_function_creators = 1;

delimiter //                                                         # 声明函数
    create function email_by_id(emp_id int)
        returns varchar(25)
    begin
        return ( select email from employees where employee_id = emp_id );
    end //
delimiter ;

select email_by_id(101);                                           # 调用

set @emp_id := 102;
select email_by_id(@emp_id);

# 举例3：创建存储函数 count_by_id()，参数传入 dept_id，该函数查询 dept_id 部门的
# 员工人数，并返回，数据类型为整型。
delimiter //
    create function count_by_id(dept_id int) returns int
    begin
        return ( select count(*) from employees where department_id = dept_id );
    end //
delimiter ;

set @dept_id := 50;                                                # 调用
select count_by_id(@dept_id);

# 3. 存储过程、存储函数的查看
# 方式1. 使用 show create 语句查看存储过程和函数的创建信息
show create procedure show_mgr_name;
show create function count_by_id;

# 方式 2. 使用 show status 语句查看存储过程和函数的状态信息
show procedure status;
show procedure status like 'show_max_salary';
show function status like 'email_by_id';

# 方式 3. 从 information_schema.Routines 表中查看存储过程和函数的信息
select * from information_schema.Routines where routine_name = 'email_by_id' and routine_type = 'function';
select * from information_schema.Routines where routine_name = 'show_min_salary' and routine_type = 'procedure';

# 4.存储过程、函数的修改
alter procedure show_max_salary sql security invoker comment '查询最高工资';

# 5. 存储过程、函数的删除
drop function if exists count_by_id;
drop procedure if exists show_min_salary;
