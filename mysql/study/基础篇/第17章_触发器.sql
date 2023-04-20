# 第 17 章_触发器

# 0. 准备工作
create database dbtest17;
use dbtest17;

# 1. 创建触发器
# 举例1：
create table `test_trigger`                                          # ① 创建数据表
(
    `id`     int primary key auto_increment,
    `t_note` varchar(30)
);

create table `test_trigger_log`
(
    `id`    int primary key auto_increment,
    `t_log` varchar(30)
);

select * from test_trigger;                                          # ② 查看表数据
select * from test_trigger_log;

#③ 创建触发器
# 创建名称为 before_insert_test_tri 的触发器，向 test_trigger 数据表插入数据之前，
# 向 test_trigger_log 数据表中插入 before_insert 的日志信息。
delimiter //
    create trigger before_insert_test_tri
    before insert on test_trigger
    for each row
    begin
        insert into test_trigger_log(t_log) values('before insert...');
    end //
delimiter ;

insert into test_trigger(t_note) values('tom...');                   # ④ 测试

select * from test_trigger;
select * from test_trigger_log;

# 举例2：
# 创建名称为 after_insert_test_tri 的触发器，向 test_trigger 数据表插入数据之后，
# 向 test_trigger_log 数据表中插入 after_insert 的日志信息。
delimiter $
    create trigger after_insert_test_tri
    after insert on test_trigger
    for each row
    begin
        insert into test_trigger_log(t_log) values('after insert...');
    end $
delimiter ;

# 测试
insert into test_trigger(t_note) values('jerry2...');

select * from test_trigger;
select * from test_trigger_log;

# 举例3：
# 定义触发器“salary_check_trigger”，基于员工表“employees”的insert事件，
# 在 insert 前检查将要添加的新员工薪资是否大于他领导的薪资，如果大于领导薪资，
# 则报 sqlstate_value 为 'hy000' 的错误，从而使得添加失败。

# 准备工作
create table employees as select * from atguigudb.`employees`;
create table departments as select * from atguigudb.`departments`;

desc employees;

delimiter //                                                         # 创建触发器
    create trigger salary_check_trigger
    before insert on employees
    for each row
    begin
        declare mgr_sal double;                                      # 查询到要添加的数据的 manager 的薪资
        select salary into mgr_sal from employees where employee_id = new.manager_id;
        if new.salary > mgr_sal
            then signal sqlstate 'hy000' set message_text = '薪资高于领导薪资错误';
        end if;
    end //
delimiter ;

# 测试
desc employees;

# 添加成功：依然触发了触发器 salary_check_trigger 的执行
insert into employees(employee_id,last_name,email,hire_date,job_id,salary,manager_id)
values(300,'tom','tom@126.com',curdate(),'ad_vp',8000,103);

insert into employees(employee_id,last_name,email,hire_date,job_id,salary,manager_id)
values(301,'tom1','tom1@126.com',curdate(),'ad_vp',10000,103);      # 添加失败

select * from employees;

# 2. 查看触发器
show triggers;                                                       # ① 查看当前数据库的所有触发器的定义
show create trigger salary_check_trigger;                            # ② 查看当前数据库中某个触发器的定义
# ③ 从系统库 information_schema 的 triggers 表中查询“salary_check_trigger”触发器的信息
select * from information_schema.triggers;

drop trigger if exists after_insert_test_tri;                        # 3. 删除触发器
