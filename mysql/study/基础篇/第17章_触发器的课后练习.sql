#第17章_触发器的课后练习

#练习1：

#0. 准备工作
create database test17_trigger;
use test17_trigger;

create table emps as select employee_id,last_name,salary from atguigudb.employees;
select * from emps;

# 1. 复制一张 emps 表的空表 emps_back，只有表结构，不包含任何数据
create table emps_back as select * from emps where 1 = 2;

# 2. 查询 emps_back 表中的数据
select * from emps_back;

# 3. 创建触发器 emps_insert_trigger，每当向 emps 表中添加一条记录时，同步将这条记录
# 添加到 emps_back 表中

delimiter //
    create trigger emps_insert_trigger
    after insert on emps
    for each row
    begin
        # 将新添加到 emps 表中的记录添加到 emps_back 表中
        insert into emps_back(employee_id,last_name,salary) values(new.employee_id,new.last_name,new.salary);
    end //
delimiter ;
# show triggers;

# 4. 验证触发器是否起作用
select * from emps;
select * from emps_back;
insert into emps(employee_id,last_name,salary) values(301,'tom1',3600);

# 练习2：
# 0. 准备工作：使用练习 1 中的 emps 表
# 1. 复制一张 emps 表的空表 emps_back1，只有表结构，不包含任何数据
create table emps_back1 as select * from emps where 1 = 2;

# 2. 查询emps_back1表中的数据
select * from emps_back1;

# 3. 创建触发 emps_del_trigger，每当向 emps 表中删除一条记录时，同步将删除的这条记录添加到 emps_back1 表中
delimiter //
    create trigger emps_del_trigger
    before delete on emps
    for each row
    begin
        # 将 emps 表中删除的记录，添加到 emps_back1 表中。
        insert into emps_back1(employee_id,last_name,salary) values(old.employee_id,old.last_name,old.salary);
    end //
delimiter ;

# 4. 验证触发器是否起作用
delete from emps where employee_id = 101;
delete from emps;
select * from emps;
select * from emps_back1;
