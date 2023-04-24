# 第 16 章_变量、流程控制与游标的课后练习

/*
    变量：
        系统变量 （全局系统变量、会话系统变量）
        用户自定义变量（会话用户变量、局部变量）
*/
# 练习1：测试变量的使用
# 存储函数的练习

# 0. 准备工作
create database test16_var_cursor;
use test16_var_cursor;
create table employees as select * from atguigudb.employees;
create table departments as select * from atguigudb.departments;

set global log_bin_trust_function_creators = 1;

# 无参有返回
# 1. 创建函数get_count(),返回公司的员工个数
delimiter $
    create function get_count() returns int
    begin
        declare emp_count int;                                    # 声明局部变量
        select count(*) into emp_count from employees;           # 赋值
        return emp_count;
    end $
delimiter ;

select get_count();                                                # 调用

# 有参有返回
# 2. 创建函数 ename_salary(),根据员工姓名，返回它的工资
delimiter $
    create function ename_salary(emp_name varchar(15)) returns double
    begin
        # 声明变量
        set @sal = 0;                                              # 定义了一个会话用户变量
        select salary into @sal from employees where last_name = emp_name;     # 赋值
        return @sal;
    end $
delimiter ;

select ename_salary('Abel');                                       # 调用
select @sal;

#3. 创建函数dept_sal() ,根据部门名，返回该部门的平均工资
delimiter //
    create function dept_sal(dept_name varchar(15)) returns double
    begin
        declare avg_sal double;
        select avg(salary) into avg_sal
        from employees e join departments d on e.department_id = d.department_id
        where d.department_name = dept_name;
        return avg_sal;
    end //
delimiter ;

select * from departments;                                         # 调用
select dept_sal('Marketing');

# 4. 创建函add_float()，实现传入两float，返回二者之和
delimiter //
    create function add_float(value1 float, value2 float) returns float
    begin
        declare sum_val float;
        set sum_val = value1 + value2;
        return sum_val;
    end //
delimiter ;

set @v1 := 12.2;                                                   # 调用
set @v2 = 2.3;
select add_float(@v1, @v2);

# 2. 流程控制
/*
    分支：if \ case ... when \ case when ...
    循环：loop \ while \ repeat
    其它：leave \ iterate
*/

# 1. 创建函数 test_if_case()，实现传入成绩，如果成绩 >90 ,返回 A，如果成绩 >80,返回 B，
# 如果成绩 >60,返回 C，否则返回 D;要求：分别使用if结构和case结构实现

# 方式1：if
delimiter $
    create function test_if_case1(score double)
    returns char
    begin
        #声明变量
        declare score_level char;
        if score > 90
            then set score_level = 'A';
        elseif score > 80
            then set score_level = 'B';
        elseif score > 60
            then set score_level = 'C';
        else set score_level = 'D';
        end if;
        return score_level;                                        # 返回
    end $
delimiter ;

select test_if_case1(56);                                    # 调用

# 方式2：case when ...
delimiter $
    create function test_if_case2(score double)
    returns char
    begin
        declare score_level char;                                  # 声明变量
        case
            when score > 90 then set score_level = 'A';
            when score > 80 then set score_level = 'B';
            when score > 60 then set score_level = 'C';
            else set score_level = 'D';
        end case;

        return score_level;                                        # 返回
    end $
delimiter ;

select test_if_case2(76);                                    # 调用


# 2. 创建存储过程 test_if_pro()，传入工资值，如果工资值 <3000，则删除工资为此值的员工，
# 如果 3000 <= 工资值 <= 5000,则修改此工资值的员工薪资涨 1000，否则涨工资 500
delimiter $
    create procedure test_if_pro(in sal double)
    begin
        if sal < 3000
            then delete from employees where salary = sal;
        elseif sal <= 5000
            then update employees set salary = salary + 1000 where salary = sal;
        else
            update employees set salary = salary + 500 where salary = sal;
        end if;
    end $
delimiter ;

call test_if_pro(24000);                                           # 调用
select * from employees;

# 3. 创建存储过程insert_data(),传入参数为 in 的 int 类型变量 insert_count,实现向 admin 表中
# 批量插入insert_count条记录
create table admin
(
    id        int primary          key auto_increment,
    user_name varchar(25) not null,
    user_pwd  varchar(35) not null
);

select * from admin;

delimiter $
    create procedure insert_data(in insert_count int)
    begin
        declare init_count int default 1;                          # ① 初始化条件
        while init_count <= insert_count do                       # ② 循环条件
            insert into admin(user_name, user_pwd)               # ③ 循环体
            values (concat('atguigu-', init_count), round(rand() * 1000000));
            set init_count = init_count + 1;                      # ④ 迭代条件
        end while;
    end $
delimiter ;

call insert_data(100);                                             # 调用

# 3. 游标的使用
# 创建存储过程update_salary()，参数 1 为 in 的 int 型变量 dept_id，表示部门 id；
# 参数 2 为 in 的 int 型变量 change_sal_count，表示要调整薪资的员工个数。查询指定 id 部门的员工信息，
# 按照 salary 升序排列，根据hire_date的情况，调整前 change_sal_count 个员工的薪资，详情如下。
delimiter $
    create procedure update_salary(in dept_id int, in change_sal_count int)
    begin
        # 声明变量
        declare emp_id int;                                        # 记录员工 id
        declare emp_hire_date date;                                # 记录员工入职时间
        declare init_count int default 1;                          # 用于表示循环结构的初始化条件
        declare add_sal_rate double;                               # 记录涨薪的比例

        declare emp_cursor cursor for                              # 声明游标
            select employee_id, hire_date from employees where department_id = dept_id order by salary;

        open emp_cursor;                                           # 打开游标
            while init_count <= change_sal_count do
                fetch emp_cursor into emp_id, emp_hire_date;     # 使用游标

                if (year(emp_hire_date) < 1995)
                    then set add_sal_rate = 1.2;
                elseif (year(emp_hire_date) <= 1998)
                    then set add_sal_rate = 1.15;
                elseif (year(emp_hire_date) <= 2001)
                    then set add_sal_rate = 1.10;
                else
                    set add_sal_rate = 1.05;
                end if;
                # 涨薪操作
                update employees set salary = salary * add_sal_rate where employee_id = emp_id;
                set init_count = init_count + 1;                  # 迭代条件的更新
            end while;
        close emp_cursor;                                          # 关闭游标
    end $
delimiter ;

call update_salary(50, 3);                  # 调用

select employee_id, hire_date, salary from employees where department_id = 50 order by salary asc;
