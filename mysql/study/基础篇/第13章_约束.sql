#第 13 章 约束

# 1. 基础知识
/*
    1.1 为什么需要约束？ 为了保证数据的完整性！
    1.2 什么叫约束？对表中字段的限制。
    1.3 约束的分类：
        角度1：约束的字段的个数
            单列约束 vs 多列约束

        角度2：约束的作用范围
            列级约束：将此约束声明在对应字段的后面
            表级约束：在表中所有字段都声明完，在所有字段的后面声明的约束

        角度3：约束的作用（或功能）
            ① not null (非空约束)
            ② unique  (唯一性约束)
            ③ primary key (主键约束)
            ④ foreign key (外键约束)
            ⑤ check (检查约束)
            ⑥ default (默认值约束)

    1.4 如何添加/删除约束？
        create table时添加约束
        alter table 时增加约束、删除约束
*/

# 2. 如何查看表中的约束
select * from information_schema.table_constraints where table_name = 'test1';
create database dbtest13;
use dbtest13;

# 3. not null (非空约束)
# 3.1 在 create table 时添加约束
create table test1
(
    id        int not null,
    last_name varchar(15) not null,
    email     varchar(25),
    salary    decimal(10, 2)
);
desc test1;

insert into test1(id, last_name, email, salary) values (1, 'Tom', 'tom@126.com', 3400);

# 错误：Column 'last_name' cannot be null
insert into test1(id, last_name, email, salary) values (2, null, 'tom1@126.com', 3400);

# 错误：Column 'id' cannot be null
insert into test1(id, last_name, email, salary) values (null, 'Jerry', 'jerry@126.com', 3400);
insert into test1(id, email) values (2, 'abc@126.com');

update test1 set last_name = null where id = 1;
update test1 set email = 'tom@126.com' where id = 1;

# 3.2 在 alter table 时添加约束
select * from test1;
desc test1;
alter table test1 modify email varchar(25) not null;

# 3.3 在 alter table 时删除约束
alter table test1 modify email varchar(25) null;

# 4. unique  (唯一性约束)
# 4.1 在 create table 时添加约束
create table test2
(
    id        int unique, #列级约束
    last_name varchar(15),
    email     varchar(25),
    salary    decimal(10, 2),
    constraint uk_test2_email unique (email)                     # 表级约束
);
desc test2;

select * from information_schema.table_constraints where table_name = 'test2';

# 在创建唯一约束的时候，如果不给唯一约束命名，就默认和列名相同。
insert into test2(id, last_name, email, salary) values (1, 'Tom', 'tom@126.com', 4500);

# 错误：Duplicate entry '1' for key 'test2.id'
insert into test2(id, last_name, email, salary) values (1, 'Tom1', 'tom1@126.com', 4600);

# 错误：Duplicate entry 'tom@126.com' for key 'test2.uk_test2_email'
insert into test2(id, last_name, email, salary) values (2, 'Tom1', 'tom@126.com', 4600);

# 可以向声明为unique的字段上添加null值。而且可以多次添加null
insert into test2(id, last_name, email, salary) values (2, 'Tom1', null, 4600);

insert into test2(id, last_name, email, salary) values (3, 'Tom2', null, 4600);
select * from test2;

# 4.2 在 alter table 时添加约束
desc test2;
update test2 set salary = 5000 where id = 3;
alter table test2 add constraint uk_test2_sal unique (salary); # 方式 1
alter table test2 modify last_name varchar(15) unique;          # 方式 2

# 4.3 复合的唯一性约束
create table user
(
    id       int,
    name     varchar(15),
    password varchar(25),
    constraint uk_user_name_pwd unique (name, password)                  # 表级约束
);

insert into user values (1, 'Tom', 'abc');

# 可以成功的：
insert into user values (1, 'Tom1', 'abc');
select * from user;

# 案例：复合的唯一性约束的案例
# 学生表
create table student
(
    sid    int,                                                    # 学号
    sname  varchar(20),                                            # 姓名
    tel    char(11) unique key,                                    # 电话
    cardid char(18) unique key                                     # 身份证号
);

# 课程表
create table course
(
    cid   int,                                                     # 课程编号
    cname varchar(20)                                              # 课程名称
);

# 选课表
create table student_course
(
    id    int,
    sid   int,                                                     # 学号
    cid   int,                                                     # 课程编号
    score int,
    unique key (sid, cid)                                         # 复合唯一
);
insert into student values (1, '张三', '13710011002', '101223199012015623');   # 成功
insert into student values (2, '李四', '13710011003', '101223199012015624');   # 成功
insert into course values (1001, 'Java'), (1002, 'MySQL');         # 成功

select * from student;
select * from course;

insert into student_course values (1, 1, 1001, 89), (2, 1, 1002, 90), (3, 2, 1001, 88), (4, 2, 1002, 56); # 成功
select * from student_course;

# 错误：Duplicate entry '2-1002' for key 'student_course.sid'
insert into student_course values (5, 2, 1002, 67);

# 4.4 删除唯一性约束
    -- 添加唯一性约束的列上也会自动创建唯一索引
    -- 删除唯一约束只能通过删除唯一索引的方式删除
    -- 删除时需要指定唯一索引名，唯一索引名就和唯一约束名一样
    -- 如果创建唯一约束时未指定名称，单列：默认和列名相同；组合列：默认和()中排在第一个的列名相同
select * from information_schema.table_constraints where table_name = 'student_course';
select * from information_schema.table_constraints where table_name = 'test2';
desc test2;

# 如何删除唯一性索引
alter table test2 drop index last_name;
alter table test2 drop index uk_test2_sal;

# 5. primary key (主键约束)
# 5.1 在create table 时添加约束

# 一个表中最多只能有一个主键约束
create table test3                                                 # 错误：Multiple primary key defined
(
    id        int primary key,                                     # 列级约束
    last_name varchar(15) primary key,
    salary    decimal(10, 2),
    email     varchar(25)
);

# 主键约束特征：非空且唯一，用于唯一的标识表中的一条记录
create table test4
(
    id        int primary key,                                     # 列级约束
    last_name varchar(15),
    salary    decimal(10, 2),
    email     varchar(25)
);

# mysql 的主键名总是 primary，就算自己命名了主键约束名也没用
create table test5
(
    id        int,
    last_name varchar(15),
    salary    decimal(10, 2),
    email     varchar(25),
    constraint pk_test5_id primary key (id)                      # 没有必要起名字，表级约束
);

select * from information_schema.table_constraints where table_name = 'test5';
insert into test4(id, last_name, salary, email) values (1, 'Tom', 4500, 'tom@126.com');

# 错误：Duplicate entry '1' for key 'test4.PRIMARY'
insert into test4(id, last_name, salary, email) values (1, 'Tom', 4500, 'tom@126.com');

# 错误：Column 'id' cannot be null
insert into test4(id, last_name, salary, email) values (null, 'Tom', 4500, 'tom@126.com');
select * from test4;

create table user1
(
    id       int,
    name     varchar(15),
    password varchar(25),
    primary key (name, password)
);
# 如果是多列组合的复合主键约束，那么这些列都不允许为空值，并且组合的值不允许重复
insert into user1 values (1, 'Tom', 'abc');
insert into user1 values (1, 'Tom1', 'abc');
insert into user1 values (1, null, 'abc');                         # 错误：Column 'name' cannot be null
select * from user1;

# 5.2 在 alter table 时添加约束
create table test6(id int, last_name varchar(15), salary decimal(10, 2), email varchar(25));
desc test6;
alter table test6 add primary key (id);

# 5.3 如何删除主键约束 (在实际开发中，不会去删除表中的主键约束！)
alter table test6 drop primary key;

# 6. 自增长列：auto_increment
# 6.1 在 create table 时添加
create table test7(id int primary key auto_increment, last_name varchar(15));
# 开发中，一旦主键作用的字段上声明有 auto_increment，则我们在添加数据时，就不要给主键对应的字段去赋值了

insert into test7(last_name) values ('Tom');
select * from test7;

# 当我们向主键（含AUTO_INCREMENT）的字段上添加 0 或 null时，实际上会自动的往上添加指定的字段的数值
insert into test7(id, last_name) values (0, 'Tom');
insert into test7(id, last_name) values (null, 'Tom');
insert into test7(id, last_name) values (10, 'Tom');
insert into test7(id, last_name) values (-10, 'Tom');

# 6.2 在 alter table 时添加
create table test8 (id int primary key, last_name varchar(15));
desc test8;
alter table test8 modify id int auto_increment;

# 6.3 在 alter table 时删除
alter table test8 modify id int;

# 6.4 MySQL 8.0 新特性—自增变量的持久化
create table test9 (id int primary key auto_increment);          # 在 MySQL 5.7中演示
insert into test9 values (0), (0), (0), (0);
select * from test9;

delete from test9 where id = 4;
insert into test9 values (0);
delete from test9 where id = 5;

# 重启服务器
select * from test9;
insert into test9 values (0);

create table test9 (id int primary key auto_increment);          # 在 MySQL 8.0 中演示
insert into test9 values (0), (0), (0), (0);
select * from test9;

delete from test9 where id = 4;
insert into test9 values (0);
delete from test9 where id = 5;

# 重启服务器
select * from test9;
insert into test9 values (0);

# 7.foreign key (外键约束)
# 7.1 在 create table 时添加：主表和从表；父表和子表
create table dept1 (dept_id int, dept_name varchar(15));       # ① 先创建主表
create table emp1                                                # ② 再创建从表
(
    emp_id        int primary key auto_increment,
    emp_name      varchar(15),
    department_id int,
    constraint fk_emp1_dept_id foreign key (department_id) references dept1 (dept_id) # 表级约束
);
# 上述操作报错，因为主表中的 dept_id 上没有主键约束或唯一性约束。
alter table dept1 add primary key (dept_id);                     # ③ 添加
desc dept1;

create table emp1                                                  # ④ 再创建从表
(
    emp_id        int primary key auto_increment,
    emp_name      varchar(15),
    department_id int,
    constraint fk_emp1_dept_id foreign key (department_id) references dept1 (dept_id) #表级约束
);

desc emp1;
select * from information_schema.table_constraints where table_name = 'emp1';

# 7.2 演示外键的效果
insert into emp1 values (1001, 'Tom', 10);                         # 添加失败
# 在主表 dept1 中添加了 10 号部门以后，我们就可以在从表中添加 10 号部门的员工
insert into dept1 values (10, 'IT');
insert into emp1 values (1001, 'Tom', 10);

delete from dept1 where dept_id = 10;                            # 删除失败
update dept1 set dept_id = 20 where dept_id = 10;               # 更新失败

# 7.3 在 alter table 时添加外键约束
create table dept2(dept_id int primary key, dept_name varchar(15));
create table emp2(emp_id int primary key auto_increment, emp_name varchar(15), department_id int);

alter table emp2 add constraint fk_emp2_dept_id foreign key (department_id) references dept2 (dept_id);
select * from information_schema.table_constraints where table_name = 'emp2';

# 7.4 ###  约束等级
    -- Cascade 方式：在父表上 update/delete 记录时，同步 update/delete 到子表的匹配记录
    -- Set null方式：在父表上 update/delete 记录时，将子表上匹配记录的列设为 null，
        -- 但是要注意子表的外键列不能为 not null
    -- No action 方式：如果子表中有匹配的记录，则不允许对父表对应候选键进行 update/delete 操作
    -- Restrict 方式：同 no action， 都是立即检查外键约束
    -- Set default 方式（在可视化工具 SQLyog 中可能显示空白）：父表有变更时，
        -- 子表将外键列设置成一个默认的值，但Innodb不能识别

create table dept                                                  # on update cascade on delete set null
(
    did   int primary key,                                         # 部门编号
    dname varchar(50)                                              # 部门名称
);

create table emp
(
    eid    int primary key,                                        # 员工编号
    ename  varchar(5),                                             # 员工姓名
    deptid int,                                                    # 员工所在的部门
    foreign key (deptid) references dept (did) on update cascade on delete set null
);  # 把修改操作设置为级联修改等级，把删除操作设置为 set null 等级

insert into dept values (1001, '教学部');
insert into dept values (1002, '财务部');
insert into dept values (1003, '咨询部');

insert into emp values (1, '张三', 1001);                            # 在添加这条记录时，要求部门表有 1001 部门
insert into emp values (2, '李四', 1001);
insert into emp values (3, '王五', 1002);

update dept set did = 1004 where did = 1002;
delete from dept where did = 1004;
select * from dept;
select * from emp;
# 结论：对于外键约束，最好是采用: on update cascade on delete restrict 的方式。

# 7.5 删除外键约束：一个表中可以声明有多个外键约束
use atguigudb;
select * from information_schema.table_constraints where table_name = 'employees';

use dbtest13;
select * from information_schema.table_constraints where table_name = 'emp1';

alter table emp1 drop foreign key fk_emp1_dept_id;               # 删除外键约束
show index from emp1;                                             # 再手动的删除外键约束对应的普通索引
alter table emp1 drop index fk_emp1_dept_id;

# 8. check 约束
# Mysql5.7 不支持 check 约束，Mysql8.0 支持 check 约束
create table test10(id int, last_name varchar(15), salary decimal(10, 2) check (salary > 2000));

insert into test10 values (1, 'Tom', 2500);
insert into test10 values (2, 'Tom1', 1500);                       # 添加失败

select * from test10;

# 9.default 约束
# 9.1 在 create table 添加约束
create table test11(id int, last_name varchar(15), salary decimal(10, 2) default 2000);

desc test11;

insert into test11(id, last_name, salary) values (1, 'Tom', 3000);
insert into test11(id, last_name) values (2, 'Tom1');

select * from test11;

# 9.2 在 alter table 添加约束
create table test12 (id int, last_name varchar(15), salary decimal(10, 2));
desc test12;
alter table test12 modify salary decimal(8, 2) default 2500;

# 9.3 在 alter table 删除约束
alter table test12 modify salary decimal(8, 2);
show create table test12;
