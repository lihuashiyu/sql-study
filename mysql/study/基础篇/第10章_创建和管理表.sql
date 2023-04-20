# 第 10 章_创建和管理表

select * from `order`;

# 1. 创建和管理数据库

# 1.1 如何创建数据库
create database `mytest1`;                                           # 方式1：创建的此数据库使用的是默认的字符集
show create database `mytest1`;                                      # 查看创建数据库的结构

create database `mytest2` character set 'gbk';                       # 方式2：显式了指名了要创建的数据库的字符集
show create database `mytest2`;

# 方式3（推荐）：如果要创建的数据库已经存在，则创建不成功，但不会报错。
create database if not exists `mytest2` character set 'utf8';
create database if not exists `mytest3` character set 'utf8';        # 如果要创建的数据库不存在，则创建成功
show databases;

# 1.2 管理数据库
show databases;                                                      # 查看当前连接中的数据库都有哪些
use `atguigudb`;                                                      # 切换数据库
show tables;                                                         # 查看当前数据库中保存的数据表
select database() from `dual`;                                        # 查看当前使用的数据库
show tables from `mysql`;                                             # 查看指定数据库下保存的数据表

# 1.3 修改数据库
show create database `mytest2`;                                      # 更改数据库字符集
alter database `mytest2` character set 'utf8';

# 1.4 删除数据库
# 方式1：如果要删除的数据库存在，则删除成功。如果不存在，则报错
drop database `mytest1`;
show databases;
# 方式2：推荐。 如果要删除的数据库存在，则删除成功。如果不存在，则默默结束，不会报错。
drop database if exists `mytest1`;
drop database if exists `mytest2`;

# 2. 如何创建数据表
use `atguigudb`;
show create database `atguigudb`;                                    # 默认使用的是 utf8
show tables;

# 方式1："白手起家"的方式
# 如果创建表时没有指明使用的字符集，则默认使用表所在的数据库的字符集。
create table if not exists `myemp1`                                  # 需要用户具备创建表的权限
(
    `id`        int,
    `emp_name`  varchar(15),                     # 使用 varchar 来定义字符串，在使用 varchar 时必须指明长度
    `hire_date` date
);

desc `myemp1`;                                                       # 查看表结构
show create table `myemp1`;                                          # 查看创建表的语句结构
select * from `myemp1`;                                              # 查看表数据

# 方式2：基于现有的表，同时导入数据
create table `myemp2` as select `employee_id`, `last_name`, `salary` from `employees`;
desc `myemp2`;
desc `employees`;
select * from `myemp2`;

# 说明1：查询语句中字段的别名，可以作为新创建的表的字段的名称。
# 说明2：此时的查询语句可以结构比较丰富，使用前面章节讲过的各种 SELECT
create table `myemp3` as
    select `e`.`employee_id` `emp_id`, `e`.`last_name` `lname`, `d`.`department_name`
from `employees` `e` join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

select * from `myemp3`;
desc `myemp3`;

# 练习1：创建一个表employees_copy，实现对employees表的复制，包括表数据
create table `employees_copy` as select * from `employees`;
select * from `employees_copy`;

# 练习2：创建一个表employees_blank，实现对employees表的复制，不包括表数据
create table `employees_blank` as select * from `employees`          # where department_id > 10000;
where 1 = 2;                                                       # 山无陵，天地合，乃敢与君绝
select * from `employees_blank`;

# 3. 修改表  --> alter table
desc `myemp1`;

# 3.1 添加一个字段
alter table `myemp1` add `salary` double(10, 2);                     # 默认添加到表中的最后一个字段的位置
alter table `myemp1` add `phone_number` varchar(20) first;
alter table `myemp1` add `email` varchar(45) after `emp_name`;

# 3.2 修改一个字段：数据类型、长度、默认值（略）
alter table `myemp1` modify `emp_name` varchar(25);
alter table `myemp1` modify `emp_name` varchar(35) default 'aaa';

# 3.3 重命名一个字段
alter table `myemp1` change `salary` `monthly_salary` double(10, 2);
alter table `myemp1` change `email` `my_email` varchar(50);

# 3.4 删除一个字段
alter table `myemp1` drop column `my_email`;

# 4. 重命名表
#方式1：
rename table `myemp1` to `myemp11`;
desc `myemp11`;

# 方式2：
alter table `myemp2` rename to `myemp12`;
desc `myemp12`;

# 5. 删除表
# 不光将表结构删除掉，同时表中的数据也删除掉，释放表空间
drop table if exists `myemp2`;
drop table if exists `myemp12`;

# 6. 清空表
# 清空表，表示清空表中的所有数据，但是表结构保留。
select * from `employees_copy`;
truncate table `employees_copy`;

select * from `employees_copy`;
desc `employees_copy`;

# 7. DCL 中 COMMIT 和 ROLLBACK
# COMMIT:提交数据。一旦执行COMMIT，则数据就被永久的保存在了数据库中，意味着数据不可以回滚。
# ROLLBACK:回滚数据。一旦执行ROLLBACK,则可以实现数据的回滚。回滚到最近的一次COMMIT之后。

# 8. 对比 TRUNCATE TABLE 和 DELETE FROM
# 相同点：都可以实现对表中所有数据的删除，同时保留表结构。
# 不同点：
#	TRUNCATE TABLE：一旦执行此操作，表数据全部清除。同时，数据是不可以回滚的。
#	DELETE FROM：一旦执行此操作，表数据可以全部清除（不带WHERE）。同时，数据是可以实现回滚的。

/*
9. DDL 和 DML 的说明
  ① DDL的操作一旦执行，就不可回滚。指令SET autocommit = FALSE对DDL操作失效。(因为在执行完DDL
    操作之后，一定会执行一次COMMIT。而此COMMIT操作不受SET autocommit = FALSE影响的。)
  
  ② DML的操作默认情况，一旦执行，也是不可回滚的。但是，如果在执行DML之前，执行了 
    SET autocommit = FALSE，则执行的DML操作就可以实现回滚。

*/
# 演示：DELETE FROM 
#1)
commit;
#2)
select * from `myemp3`;
#3)
set autocommit = false;
#4)
delete from `myemp3`;
#5)
select * from `myemp3`;
#6)
rollback;
#7)
select * from `myemp3`;

# 演示：TRUNCATE TABLE
#1)
commit;
#2)
select *
from `myemp3`;
#3)
set autocommit = false;
#4)
truncate table `myemp3`;
#5)
select * from `myemp3`;
#6)
rollback;
#7)
select * from `myemp3`;

#######################
# 9.测试MySQL8.0的新特性：DDL的原子化
create database `mytest`;
use `mytest`;
create table `book1`
(
    `book_id` int,
    `rr` book_name varchar (255)
);

show tables;
drop table `book1`,`book2`;
show tables
