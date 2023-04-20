# 第 13 章 约束的课后练习

# 练习 1：
create database `test04_emp`;
use `test04_emp`;
create table `emp2` (`id` int, `emp_name` varchar(15));
create table `dept2` (`id` int, `dept_name` varchar(15));

# 1.向表 emp2 的 id 列中添加 primary key 约束
alter table `emp2` add constraint `pk_emp2_id` primary key (`id`);

# 2.向表 dept2 的 id 列中添加 primary key 约束
alter table `dept2` add primary key (`id`);

# 3.向表 emp2 中添加列 dept_id，并在其中定义 foreign key 约束，与之相关联的列是 dept2 表中的 id 列
alter table `emp2` add `dept_id` int;
desc `emp2`;
alter table `emp2` add constraint `fk_emp2_deptid` foreign key (`dept_id`) references `dept2` (`id`);

# 练习2：
# 承接《第11章_数据处理之增删改》的综合案例。
use `test01_library`;
desc `books`;

# 根据题目要求给 books 表中的字段添加约束
alter table `books` add primary key (`id`);                          # 方式1
alter table `books` modify `id` int auto_increment;
alter table `books` modify `id` int primary key auto_increment;      # 方式2

alter table `books` modify `NAME` varchar(50) not null;              # 针对于非 id 字段的操作
alter table `books` modify `AUTHORS` varchar(100) not null;
alter table `books` modify `price` float not null;
alter table `books` modify `pubdate` year not null;
alter table `books` modify `num` int not null;

# 练习3：
# 1. 创建数据库test04_company
create database if not exists `test04_company` character set 'utf8';
use `test04_company`;

# 2. 按照下表给出的表结构在 test04_company 数据库中创建两个数据表 offices 和 employees
create table if not exists `offices`
(
    `officeCode` int(10) primary key,
    `city`       varchar(50) not null,
    `address`    varchar(50),
    `country`    varchar(50) not null,
    `postalCode` varchar(15),
    constraint `uk_off_poscode` unique (`postalCode`)
);
desc `offices`;

create table `employees`
(
    `employeeNumber` int primary key auto_increment,
    `lastName`       varchar(50) not null,
    `firstName`      varchar(50) not null,
    `mobile`         varchar(25) unique,
    `officeCode`     int(10)     not null,
    `jobTitle`       varchar(50) not null,
    `birth`          datetime    not null,
    `note`           varchar(255),
    `sex`            varchar(5),
    constraint `fk_emp_offcode` foreign key (`officeCode`) references `offices` (`officeCode`)
);
desc `employees`;

# 3. 将表 employees 的 mobile 字段修改到 officeCode 字段后面
alter table `employees` modify `mobile` varchar(25) after `officeCode`;

# 4. 将表 employees 的 birth 字段改名为 employee_birth
alter table `employees` change `birth` `employee_birth` datetime;

# 5. 修改 sex 字段，数据类型为 char(1)，非空约束
alter table `employees` modify `sex` char(1) not null;

# 6. 删除字段 note
alter table `employees` drop column `note`;

# 7. 增加字段名 favoriate_activity，数据类型为 varchar(100)
alter table `employees` add `favoriate_activity` varchar(100);

# 8. 将表 employees 名称修改为 employees_info
rename table `employees` to `employees_info`;
desc `employees`;                                          # Table 'test04_company.employees' doesn't exist
desc `employees_info`;
