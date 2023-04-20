# 第 16 章_变量、流程控制与游标

# 1. 变量
# 1.1 变量： 系统变量（全局系统变量、会话系统变量）  vs 用户自定义变量

# 1.2 查看系统变量
show global variables;                                               # 查询全局系统变量
show session variables;                                              # 查询会话系统变量
show variables;                                                      # 默认查询的是会话系统变量
show global variables like 'admin_%';                                # 查询部分系统变量
show variables like 'character_%';

# 1.3 查看指定系统变量
select @@global.max_connections;
select @@global.character_set_client;

select @@global.pseudo_thread_id;                                  # 错误
select @@session.max_connections;                                  # 错误
select @@session.character_set_client;                             # 先查询会话系统变量，再查询全局系统变量
select @@session.pseudo_thread_id;
select @@character_set_client from dual;

# 1.4 修改系统变量的值
# 全局系统变量：
set @@global.max_connections = 161;                                 # 方式 1
set global max_connections = 171;                                   # 方式 2
# 针对于当前的数据库实例是有效的，一旦重启 mysql 服务，就失效了

# 会话系统变量：
set @@session.character_set_client = 'gbk';                          # 方式 1
set session character_set_client = 'gbk';                            # 方式 2
# 针对于当前会话是有效的，一旦结束会话，重新建立起新的会话，就失效了。

# 1.5 用户变量
/*
    ① 用户变量 ： 会话用户变量 vs 局部变量
    ② 会话用户变量：使用"@"开头，作用域为当前会话。
    ③ 局部变量：只能使用在存储过程和存储函数中的。
*/

# 1.6 会话用户变量
/*
    ① 变量的声明和赋值：
        # 方式1：“=”或“:=”
        SET @用户变量 = 值;
        SET @用户变量 := 值;

        # 方式2：“:=” 或 INTO关键字
        select @用户变量 := 表达式 [from 等子句];
        select 表达式 into @用户变量  [from 等子句];

    ② 使用
    select @变量名
*/
# 准备工作
create database `dbtest16`;
use `dbtest16`;
create table `employees` as select * from `atguigudb`.`employees`;
create table `departments` as select * from `atguigudb`.`departments`;

select * from `employees`;
select * from `departments`;

# 测试：
set @`m1` = 1;                                                       # 方式1
set @`m2` := 2;
set @`sum` := @`m1` + @`m2`;
select @`sum`;

select @`count` := count(*) from `employees`;                        # 方式 2
select @`count`;

select avg(`salary`) into @`avg_sal` from `employees`;
select @`avg_sal`;

# 1.7 局部变量
/*
    1、局部变量必须满足：
        ① 使用 declare 声明
        ② 声明并使用在begin ... end 中 （使用在存储过程、函数中）
        ③ declare 的方式声明的局部变量必须声明在 begin 中的首行的位置。

    2、声明格式：
        declare 变量名 类型 [default 值];              # 如果没有 default 子句，初始值为 null

    3、赋值：
        方式1：
            set 变量名=值;
            set 变量名:=值;
        方式2：
            select 字段名或表达式 into 变量名 from 表;

    4、使用
        select 局部变量名;
*/

# 举例：
delimiter //
    create procedure `test_var`()
    begin
        declare `a` int default 0;                                   # 1、声明局部变量
        declare `b` int;
        # declare a, b int default 0;
        declare `emp_name` varchar(25);

        set `a` = 1;                                                 # 2、赋值
        set `b` := 2;
        select `last_name` into `emp_name` from `employees` where `employee_id` = 101;
        select `a`, `b`, `emp_name`;                                   # 3、使用
    end //
delimiter ;

call `test_var`();                                                   # 调用存储过程

# 举例1：声明局部变量，并分别赋值为 employees 表中 employee_id 为 102 的 last_name 和 salary
delimiter //
    create procedure `test_pro`()
    begin
        declare `emp_name` varchar(25);                              # 声明
        declare `sal`      double(10, 2) default 0.0;
        select `last_name`, `salary` into `emp_name`, `sal` from `employees` where `employee_id` = 102;
        select `emp_name`, `sal`;                                     # 使用
    end //
delimiter ;

call `test_pro`();                                                   # 调用存储过程

select `last_name`, `salary` from `employees` where `employee_id` = 102;

# 举例2：声明两个变量，求和并打印 （分别使用会话用户变量、局部变量的方式实现）
set @`v1` = 10;                                                      # 方式1：使用会话用户变量
set @`v2` := 20;
set @`result` := @`v1` + @`v2`;

select @`result`;                                                    # 查看

# 方式2：使用局部变量
delimiter //
    create procedure `add_value`()
    begin
        declare `value1`,`value2`,`sum_val` int;                     # 声明
        set `value1` = 10;                                         # 赋值
        set `value2` := 100;
        set `sum_val` = `value1` + `value2`;                         # 使用
        select `sum_val`;
    end //
delimiter ;

call `add_value`();                                                # 调用存储过程

# 举例3：创建存储过程“different_salary”查询某员工和他领导的薪资差距，并用 in 参数 emp_id 接收员工 id，
# 用 out 参数 dif_salary 输出薪资差距结果。
delimiter //
    create procedure `different_salary`(in `emp_id` int, out `dif_salary` double)
    begin
        # 分析：查询出 emp_id 员工的工资;
        # 查询出 emp_id 员工的管理者的 id;
        # 查询管理者 id 的工资;
        # 计算两个工资的差值

        # 声明变量
        declare `emp_sal` double default 0.0;                        # 记录员工的工资
        declare `mgr_sal` double default 0.0;                        # 记录管理者的工资
        declare `mgr_id`  int    default 0;                          # 记录管理者的 id

        # 赋值
        select `salary`     into `emp_sal` from `employees` where `employee_id` = `emp_id`;
        select `manager_id` into `mgr_id`  from `employees` where `employee_id` = `emp_id`;
        select `salary`     into `mgr_sal` from `employees` where `employee_id` = `mgr_id`;

        set `dif_salary` = `mgr_sal` - `emp_sal`;
    end //
delimiter ;

set @`emp_id` := 103;                                                # 调用存储过程
set @`dif_sal` := 0;
call `different_salary`(@`emp_id`, @`dif_sal`);
select @`dif_sal`;

select * from `employees`;

# 2. 定义条件和处理程序
# 2.1 错误演示：
insert into `employees`(`last_name`) values ('Tom');                 # Field 'email' doesn't have a default value
desc `employees`;

# 错误演示：
delimiter //
    create procedure `UpdateDataNoCondition`()
    begin
        set @`x` = 1;
        update `employees` set `email` = null where `last_name` = 'Abel';
        set @`x` = 2;
        update `employees` set `email` = 'aabbel' where `last_name` = 'Abel';
        set @`x` = 3;
    end //
delimiter ;

call `UpdateDataNoCondition`();                                      # Column 'email' cannot be null
select @`x`;


# 2.2 定义条件
# 格式：declare 错误名称 condition for 错误码（或错误条件）

# 举例1：定义“Field_Not_Be_NULL”错误名与MySQL中违反非空约束的错误类型是“ERROR 1048 (23000)”对应。
decalare Field_Not_Be_NULL condition for 1048;                        # 方式1：使用 MySQL_error_code
declare Field_Not_Be_NULL condition for sqlstate '23000';            # 方式2：使用 sqlstate_value

# 举例2：定义"ERROR 1148(42000)"错误，名称为command_not_allowed。
declare command_not_allowed condition for 1148;                      # 方式1：使用 MySQL_error_code
declare command_not_allowed condition for sqlstate '42000';          # 方式2：使用 sqlstate_value

# 2.3 定义处理程序
# 格式：declare 处理方式 handler for 错误类型 处理语句
declare continue handler `FOR` sqlstate '42S02' set @info = 'NO_SUCH_TABLE';   # 方法1：捕获 sqlstate_value
declare continue handler `FOR` 1146 set @info = 'NO_SUCH_TABLE';      # 方法2：捕获 mysql_error_value

declare no_such_table condition for 1146;                            # 方法3：先定义条件，再调用
declare continue handler `FOR` no_such_table set @info = 'NO_SUCH_TABLE';

declare exit handler `FOR` sqlwarning set @info = 'ERROR';            # 方法4：使用 sqlwarning
declare exit handler `FOR` not found set @info = 'NO_SUCH_TABLE';     # 方法5：使用not found
declare exit handler `FOR` sqlexception set @info = 'ERROR';          # 方法6：使用 sqlexception

# 2.4 案例的处理
drop procedure `UpdateDataNoCondition`;

# 重新定义存储过程，体现错误的处理程序
delimiter //
    create procedure `UpdateDataNoCondition`()
    begin
        # 声明处理程序
        declare continue handler for 1048 set @`prc_value` = -1;     # 处理方式 1
        # declare continue handler for sqlstate '23000' set @prc_value = -1;   # 处理方式 2
        set @`x` = 1;
        update `employees` set `email` = null where `last_name` = 'Abel';
        set @`x` = 2;
        update `employees` set `email` = 'aabbel' where `last_name` = 'Abel';
        set @`x` = 3;
    end //
delimiter ;

call `UpdateDataNoCondition`();                                      # 调用存储过程
select @`x`, @`prc_value`;                                            # 查看变量

# 2.5 再举一个例子：
# 创建一个名称为“InsertDataWithCondition”的存储过程
create table `departments` as select * from `atguigudb`.`departments`;    # ① 准备工作
desc `departments`;
alter table `departments` add constraint `uk_dept_name` unique (`department_id`);

delimiter //                                                         # ② 定义存储过程：
    create procedure `InsertDataWithCondition`()
    begin
        set @`x` = 1;
        insert into `departments`(`department_name`) values ('测试');
        set @`x` = 2;
        insert into `departments`(`department_name`) values ('测试');
        set @`x` = 3;
    end //
delimiter ;

call `InsertDataWithCondition`();                                    # ③ 调用
select @`x`;                                                         # 2

drop procedure if exists `InsertDataWithCondition`;                  # ④ 删除此存储过程

delimiter //                                                        # ⑤ 重新定义存储过程（考虑到错误的处理程序）
    create procedure `InsertDataWithCondition`()
    begin
        # 处理程序
        # declare exit handler for 1062 set @pro_value = -1;         # 方式1
        # declare exit handler for sqlstate '23000' set @pro_value = -1;       # 方式 2
        # 定义条件
        declare `duplicate_entry` condition for 1062;                 # 方式 3
        declare exit handler for `duplicate_entry` set @`pro_value` = -1;

        set @`x` = 1;
        insert into `departments`(`department_name`) values ('测试');
        set @`x` = 2;
        insert into `departments`(`department_name`) values ('测试');
        set @`x` = 3;
    end //
delimiter ;

call `InsertDataWithCondition`();                                    # 调用
select @`x`, @`pro_value`;

# 3. 流程控制
# 3.1 分支结构之 if
delimiter //                                                         # 举例1
    create procedure `test_if`()
    begin
        # declare stu_name varchar(15);                              # 情况1：声明局部变量

        # if stu_name is null
        #    then select 'stu_name is null';
        # end if;

        # declare email varchar(25) default 'aaa';                   # 情况2：二选一

        # if email is null
        #    then select 'email is null';
        # else
        #    select 'email is not null';
        # end if;

        declare `age` int default 20;                                # 情况3：多选一

        if `age` > 40
            then select '中老年';
        elseif `age` > 18
            then select '青壮年';
        elseif `age` > 8
            then select '青少年';
        else select '婴幼儿';
        end if;
    end //
delimiter ;

call `test_if`();                                                    # 调用
drop procedure `test_if`;

# 举例2：声明存储过程“update_salary_by_eid1”，定义 in 参数 emp_id，输入员工编号。
# 判断该员工薪资如果低于 8000 元并且入职时间超过 5 年，就涨薪 500 元；否则就不变
delimiter //
    create procedure `update_salary_by_eid1`(in `emp_id` int)
    begin
        # 声明局部变量
        declare `emp_sal` double;                                    # 记录员工的工资
        declare `hire_year` double;                                  # 记录员工入职公司的年头
        # 赋值
        select `salary` into `emp_sal` from `employees` where `employee_id` = `emp_id`;
        select datediff(curdate(), `hire_date`) / 365 into `hire_year` from `employees` where `employee_id` = `emp_id`;
        # 判断
        if `emp_sal` < 8000 and `hire_year` >= 5
            then update `employees` set `salary` = `salary` + 500 where `employee_id` = `emp_id`;
        end if;
    end //
delimiter ;

call `update_salary_by_eid1`(104);                                   # 调用存储过程

select datediff(curdate(), `hire_date`) / 365, `employee_id`, `salary`
from `employees`
where `salary` < 8000 and datediff(curdate(), `hire_date`) / 365 >= 5;

drop procedure `update_salary_by_eid1`;

# 举例3：声明存储过程“update_salary_by_eid2”，定义 in 参数 emp_id，输入员工编号。
# 判断该员工薪资如果低于 9000 元并且入职时间超过 5 年，就涨薪 500 元；否则就涨薪 100 元。
delimiter //
    create procedure `update_salary_by_eid2`(in `emp_id` int)
    begin
        # 声明局部变量
        declare `emp_sal` double;                                    # 记录员工的工资
        declare `hire_year` double;                                  # 记录员工入职公司的年头
        # 赋值
        select `salary` into `emp_sal` from `employees` where `employee_id` = `emp_id`;
        select datediff(curdate(), `hire_date`) / 365 into `hire_year` from `employees` where `employee_id` = `emp_id`;
        # 判断
        if `emp_sal` < 9000 and `hire_year` >= 5
            then update `employees` set `salary` = `salary` + 500 where `employee_id` = `emp_id`;
        else
            update `employees` set `salary` = `salary` + 100 where `employee_id` = `emp_id`;
        end if;
    end //
delimiter ;

call `update_salary_by_eid2`(103);                                   # 调用
call `update_salary_by_eid2`(104);

select * from `employees` where `employee_id` in (103, 104);

#举例4：声明存储过程“update_salary_by_eid3”，定义IN参数emp_id，输入员工编号。
#判断该员工薪资如果低于9000元，就更新薪资为9000元；薪资如果大于等于9000元且
#低于10000的，但是奖金比例为NULL的，就更新奖金比例为0.01；其他的涨薪100元。

delimiter //
    create procedure `update_salary_by_eid3`(in `emp_id` int)
    begin
        # 声明变量
        declare `emp_sal` double;                                    # 记录员工工资
        declare `bonus`   double;                                    # 记录员工的奖金率
        # 赋值
        select `salary`         into `emp_sal` from `employees` where `employee_id` = `emp_id`;
        select `commission_pct` into `bonus`   from `employees` where `employee_id` = `emp_id`;
        # 判断
        if `emp_sal` < 9000
            then update `employees` set `salary` = 9000 where `employee_id` = `emp_id`;
        elseif `emp_sal` < 10000 and `bonus` is null
            then update `employees` set `commission_pct` = 0.01 where `employee_id` = `emp_id`;
        else
            update `employees` set `salary` = `salary` + 100 where `employee_id` = `emp_id`;
        end if;
    end //
delimiter ;

call `update_salary_by_eid3`(102);                                   # 调用
call `update_salary_by_eid3`(103);
call `update_salary_by_eid3`(104);

select * from `employees` where `employee_id` in (102, 103, 104);

# 3.2 分支结构之 case
# 举例1:基本使用
delimiter //
    create procedure `test_case`()
    begin
        # 演示1：case ... when ... then ...
        /*
            declare var int default 2;

            case var
                when 1 then select 'var = 1';
                when 2 then select 'var = 2';
                when 3 then select 'var = 3';
                else        select 'other value';
            end case;
        */
        # 演示2：case when ... then ....
        declare `var1` int default 10;
        case
            when `var1` >= 100 then select '三位数';
            when `var1` >= 10  then select '两位数';
            else                   select '个数位';
        end case;
    end //
delimiter ;

call `test_case`();                                                  # 调用
drop procedure `test_case`;

# 举例2：声明存储过程“update_salary_by_eid4”，定义IN参数 emp_id，输入员工编号。
# 判断该员工薪资如果低于 9000 元，就更新薪资为 9000 元；薪资大于等于 9000 元且低于 10000 的，
# 但是奖金比例为 NULL 的，就更新奖金比例为 0.01；其他的涨薪 100 元。
delimiter //
    create procedure `update_salary_by_eid4`(in `emp_id` int)
    begin
        # 局部变量的声明
        declare `emp_sal` double;                                    # 记录员工的工资
        declare `bonus` double;                                      # 记录员工的奖金率
        # 局部变量的赋值
        select `salary`         into `emp_sal` from `employees` where `employee_id` = `emp_id`;
        select `commission_pct` into `bonus`   from `employees` where `employee_id` = `emp_id`;
        case
            when `emp_sal` < 9000
                then update `employees` set `salary` = 9000 where `employee_id` = `emp_id`;
            when `emp_sal` < 10000 and `bonus` is null
                then update `employees` set `salary` = `salary` + 100 where `employee_id` = `emp_id`;
        end case;
    end //
delimiter ;

call `update_salary_by_eid4`(103);                                   # 调用
call `update_salary_by_eid4`(104);
call `update_salary_by_eid4`(105);

select * from `employees` where `employee_id` in (103, 104, 105);

# 举例3：声明存储过程 update_salary_by_eid5，定义 in 参数 emp_id，输入员工编号。
# 判断该员工的入职年限，如果是0年，薪资涨50；如果是1年，薪资涨100；
# 如果是2年，薪资涨200；如果是3年，薪资涨300；如果是4年，薪资涨400；其他的涨薪500。
delimiter //
    create procedure `update_salary_by_eid5`(in `emp_id` int)
    begin
        # 声明局部变量
        declare `hire_year` int;                                     # 记录员工入职公司的总时间（单位：年）
        # 赋值
        select round(datediff(curdate(), `hire_date`) / 365) into `hire_year` from `employees`
        where `employee_id` = `emp_id`;
        # 判断
        case `hire_year`
            when 0 then update `employees` set `salary` = `salary` + 50 where `employee_id` = `emp_id`;
            when 1 then update `employees` set `salary` = `salary` + 100 where `employee_id` = `emp_id`;
            when 2 then update `employees` set `salary` = `salary` + 200 where `employee_id` = `emp_id`;
            when 3 then update `employees` set `salary` = `salary` + 300 where `employee_id` = `emp_id`;
            when 4 then update `employees` set `salary` = `salary` + 400 where `employee_id` = `emp_id`;
            else update `employees` set `salary` = `salary` + 500 where `employee_id` = `emp_id`;
        end case;
    end //
delimiter ;

call `update_salary_by_eid5`(101);                                   # 调用
select * from `employees`;
drop procedure `update_salary_by_eid5`;

# 4.1 循环结构之LOOP
    /*
    [loop_label:] loop
        循环执行的语句
    end loop [loop_label]
*/
# 举例1：
delimiter //
    create procedure `test_loop`()
    begin
        declare `num` int default 1;                                 # 声明局部变量
        `loop_label`: loop                                           # 重新赋值
            set `num` = `num` + 1;                                    # 可以考虑某个代码程序反复执行。（略）
            if `num` >= 10 then leave `loop_label`;
            end if;
        end loop `loop_label`;
        select `num`;                                                # 查看 num
    end //
delimiter ;

call `test_loop`();                                                  # 调用

# 举例2：当市场环境变好时，公司为了奖励大家，决定给大家涨工资。
# 声明存储过程“update_salary_loop()”，声明 OUT 参数 num，输出循环次数。
# 存储过程中实现循环给大家涨薪，薪资涨为原来的 1.1 倍。直到全公司的平
# 均薪资达到 12000 结束。并统计循环次数。

delimiter //
    create procedure `update_salary_loop`(out `num` int)
    begin
        # 声明变量
        declare `avg_sal` double;                                    # 记录员工的平均工资
        declare `loop_count` int default 0;                          # 记录循环的次数
        # ① 初始化条件
        select avg(`salary`) into `avg_sal` from `employees`;          # 获取员工的平均工资
        # ② 循环条件
        `loop_lab`: loop
            if `avg_sal` >= 12000 then leave `loop_lab`; end if;      # 结束循环的条件
            # ③ 循环体
            update `employees` set `salary` = `salary` * 1.1;          # 如果低于 12000，更新员工的工资
            # ④ 迭代条件
            select avg(`salary`) into `avg_sal` from `employees`;      # 更新 avg_sal 变量的值
            set `loop_count` = `loop_count` + 1;
        end loop `loop_lab`;                                         # 记录循环次数
        set `num` = `loop_count`;                                     # 给 num 赋值
    end //
delimiter ;

select avg(`salary`) from `employees`;
call `update_salary_loop`(@`num`);
select @`num`;

# 4.2 循环结构之 while
/*
    [while_label:] while 循环条件  do
        循环体
    end while [while_label];
*/
# 举例1：
delimiter //
    create procedure `test_while`()
    begin
        declare `num` int default 1;                                 # 初始化条件
        while `num` <= 10 do                                         # 循环条件
            set `num` = `num` + 1;                                    # 循环体（略）
        end while;                                                  # 迭代条件
        select `num`;                                                # 查询
    end //
delimiter ;

call `test_while`();                                                 # 调用

# 举例2：市场环境不好时，公司为了渡过难关，决定暂时降低大家的薪资。
# 声明存储过程“update_salary_while()”，声明 out 参数 num，输出循环次数。
# 存储过程中实现循环给大家降薪，薪资降为原来的 90%。直到全公司的平均薪资达到 5000 结束并统计循环次数。
delimiter //
    create procedure `update_salary_while`(out `num` int)

    begin
        # 声明变量
        declare `avg_sal` double;                                  # 记录平均工资
        declare `while_count` int default 0;                       # 记录循环次数
        select avg(`salary`) into `avg_sal` from `employees`;        # 赋值

        while `avg_sal` > 5000 do
            update `employees` set `salary` = `salary` * 0.9;
            set `while_count` = `while_count` + 1;
            select avg(`salary`) into `avg_sal` from `employees`;
        end while;
        set `num` = `while_count`;                                   # 给 num 赋值
    end //
delimiter ;

call `update_salary_while`(@`num`);                             # 调用
select @`num`;

select avg(`salary`) from `employees`;

# 4.3 循环结构之 repeat
/*
    [repeat_label:] repeat
    　　　　循环体的语句
    until 结束循环的条件表达式
    end repeat [repeat_label]
*/

# 举例1：
delimiter //
    create procedure `test_repeat`()
    begin
        declare `num` int default 1;                                 # 声明变量
        repeat set `num` = `num` + 1; until `num` >= 10 end repeat;
        select `num`;                                                # 查看
    end //
delimiter ;

call `test_repeat`();                                                # 调用

# 举例2：当市场环境变好时，公司为了奖励大家，决定给大家涨工资:
# 声明存储过程“update_salary_repeat()”，声明out参数num，输出循环次数
# 存储过程中实现循环给大家涨薪，薪资涨为原来的1.15倍。直到全公司的平均薪资达到13000结束。并统计循环次数。
delimiter //
    create procedure `update_salary_repeat`(out `num` int)
    begin
        declare `avg_sal`      double;                               # 记录平均工资
        declare `repeat_count` int default 0;                        # 记录循环次数

        select avg(`salary`) into `avg_sal` from `employees`;          # 赋值

        repeat update `employees` set `salary` = `salary` * 1.15;
        set `repeat_count` = `repeat_count` + 1;

        select avg(`salary`) into `avg_sal` from `employees`; until `avg_sal` >= 13000 end repeat;

        set `num` = `repeat_count`;                                  # 给 num 赋值
    end //
delimiter ;

call `update_salary_repeat`(@`num`);                            # 调用
select @`num`;

select avg(`salary`) from `employees`;

/*
    凡是循环结构，一定具备4个要素：
        1. 初始化条件
        2. 循环条件
        3. 循环体
        4. 迭代条件

*/

# 5.1 leave 的使用
/*
    **举例1：**创建存储过程 “leave_begin()”，声明 int 类型的 in 参数 num。给 begin ... end 加标记名，
        并在 begin ... end 中使用 if 语句判断 num 参数的值。
            - 如果 num<=0，则使用 leave 语句退出 begin ... end；
            - 如果 num=1，则查询“employees”表的平均薪资；
            - 如果 num=2，则查询“employees”表的最低薪资；
            - 如果 num>2，则查询“employees”表的最高薪资。

    if 语句结束后查询“employees”表的总人数。
*/
delimiter //
    create procedure `leave_begin`(in `num` int)
    `begin_label`:
    begin
        if `num` <= 0
            then leave `begin_label`;
        elseif `num` = 1
            then select avg(`salary`) from `employees`;
        elseif `num` = 2
            then select min(`salary`) from `employees`;
        else
            select max(`salary`) from `employees`;
        end if;
        # 查询总人数
        select count(*) from `employees`;
    end //
delimiter ;

call `leave_begin`(1);                                               # 调用


# 举例2：当市场环境不好时，公司为了渡过难关，决定暂时降低大家的薪资。
# 声明存储过程“leave_while()”，声明 out 参数 num，输出循环次数，存储过程中使用 while
# 循环给大家降低薪资为原来薪资的 90%，直到全公司的平均薪资小于等于 10000，并统计循环次数。
delimiter //
    create procedure `leave_while`(out `num` int)
    begin
        declare `avg_sal` double;                                    # 记录平均工资
        declare `while_count` int default 0;                         # 记录循环次数

        select avg(`salary`) into `avg_sal` from `employees`;          # ① 初始化条件

        `while_label`:
        while true do                                               # ② 循环条件
            if `avg_sal` <= 10000 then leave `while_label`; end if;   # ③ 循环体

            update `employees` set `salary` = `salary` * 0.9;
            set `while_count` = `while_count` + 1;

            select avg(`salary`) into `avg_sal` from `employees`;      # ④ 迭代条件
        end while;
        set `num` = `while_count`;                                    # 赋值
    end //
delimiter ;

call `leave_while`(@`num`);                                      # 调用
select @`num`;

select avg(`salary`) from `employees`;

# 5.2 iterate 的使用
/*
    举例： 定义局部变量 num，初始值为 0。循环结构中执行 num + 1 操作。
        - 如果 num < 10，则继续执行循环；
        - 如果 num > 15，则退出循环结构；
*/
delimiter //
    create procedure `test_iterate`()
    begin
        declare `num` int default 0;
        `loop_label`: loop                                           # 赋值
            set `num` = `num` + 1;
            if `num` < 10
                then iterate `loop_label`;
            elseif `num` > 15
                then leave `loop_label`;
            end if;
            select '尚硅谷：让天下没有难学的技术';
        end loop;
    end //
delimiter ;

call `test_iterate`();

select * from `employees`;

# 6. 游标的使用
/*
    游标使用的步骤：
        ① 声明游标
        ② 打开游标
        ③ 使用游标（从游标中获取数据）
        ④ 关闭游标
*/

# 举例：创建存储过程“get_count_by_limit_total_salary()”，声明 in 参数 limit_total_salary，
# double 类型；声明 out 参数 total_count，int 类型。函数的功能可以实现累加薪资最高的几个员工的薪资值，
# 直到薪资总和达到 limit_total_salary 参数的值，返回累加的人数给 total_count。
delimiter //
    create procedure `get_count_by_limit_total_salary`(in `limit_total_salary` double, out `total_count` int)
    begin
        # 声明局部变量
        declare `sum_sal` double default 0.0;                        # 记录累加的工资总额
        declare `emp_sal` double;                                    # 记录每一个员工的工资
        declare `emp_count` int default 0;
        # 记录累加的人数
        declare `emp_cursor` cursor for select `salary` from `employees` order by `salary` desc;   # 1.声明游标
        open `emp_cursor`;                                           # 2.打开游标
            repeat                                                  # 3.使用游标
                fetch `emp_cursor` into `emp_sal`;
                set `sum_sal` = `sum_sal` + `emp_sal`;
                set `emp_count` = `emp_count` + 1; until `sum_sal` >= `limit_total_salary` end repeat;
                set `total_count` = `emp_count`;
        close `emp_cursor`;                                          # 4.关闭游标
    end //
delimiter ;

call `get_count_by_limit_total_salary`(200000, @`total_count`);      # 调用
select @`total_count`;
