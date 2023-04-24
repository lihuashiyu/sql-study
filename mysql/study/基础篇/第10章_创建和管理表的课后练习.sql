# 第10章_创建和管理表的课后练习


# 1. 创建数据库test01_office,指明字符集为utf8。并在此数据库下执行下述操作
create database if not exists test01_office character set 'utf8';
use test01_office;

# 2.	创建表 dept01
/*
    字段      类型
    id	      int(7)
    name	  varchar(25)
*/
create table if not exists dept01
(
    id   int(7),
    name varchar(25)
);


# 3.将表departments中的数据插入新表dept02中
create table dept02 as select * from atguigudb.departments;


# 4.	创建表emp01
/*
    字段            类型
    id		INT(7)
    first_name	VARCHAR (25)
    last_name	VARCHAR(25)
    dept_id		INT(7)
*/

create table emp01
(
    id         int(7),
    first_name varchar(25),
    last_name  varchar(25),
    dept_id    int(7)
);

# 5.将列last_name的长度增加到50
desc emp01;
alter table emp01 modify last_name varchar(50);

# 6.根据表employees创建emp02
create table emp02 as select * from atguigudb.employees;
show tables from test01_office;

# 7.删除表emp01
drop table emp01;

# 8.将表emp02重命名为emp01
# alter table emp02 rename to emp01;
rename table emp02 to emp01;

# 9.在表dept02和emp01中添加新列test_column，并检查所作的操作
alter table emp01 add test_column varchar(10);
desc emp01;

alter table dept02 add test_column varchar(10);
desc dept02;

# 10.直接删除表emp01中的列 department_id
alter table emp01 drop column department_id;

# 练习2：
# 1、创建数据库 test02_market
create database if not exists test02_market character set 'utf8';
use test02_market;
show create database test02_market;

# 2、创建数据表 customers
create table if not exists customers
(
    c_num     int,
    c_name    varchar(50),
    c_contact varchar(50),
    c_city    varchar(50),
    c_birth   date
);
show tables;

# 3、将 c_contact 字段移动到 c_birth 字段后面
desc customers;
alter table customers modify c_contact varchar(50) after c_birth;

# 4、将 c_name 字段数据类型改为 varchar(70)
alter table customers modify c_name varchar(70);

# 5、将c_contact字段改名为c_phone
alter table customers change c_contact c_phone varchar(50);

# 6、增加c_gender字段到c_name后面，数据类型为char(1)
alter table customers add c_gender char(1) after c_name;

# 7、将表名改为customers_info
rename table customers to customers_info;
desc customers_info;

# 8、删除字段c_city
alter table customers_info drop column c_city;

#练习3：
# 1、创建数据库test03_company
create database if not exists test03_company character set 'utf8';
use test03_company;

# 2、创建表offices
create table if not exists offices
(
    officeCode int,
    city       varchar(30),
    address    varchar(50),
    country    varchar(50),
    postalCode varchar(25)
);

desc offices;

# 3、创建表employees
create table if not exists employees
(
    empNum    int,
    lastName  varchar(50),
    firstName varchar(50),
    mobile    varchar(25),
    code      int,
    jobTitle  varchar(50),
    birth     date,
    note      varchar(255),
    sex       varchar(5)

);

desc employees;

# 4、将表employees的mobile字段修改到code字段后面
alter table employees modify mobile varchar(20) after code;

# 5、将表employees的birth字段改名为birthday
alter table employees change birth birthday date;

# 6、修改sex字段，数据类型为char(1)
alter table employees modify sex char(1);

# 7、删除字段note
alter table employees drop column note;

# 8、增加字段名favoriate_activity，数据类型为varchar(100)
alter table employees add favoriate_activity varchar(100);

# 9、将表employees的名称修改为 employees_info
rename table employees to employees_info;
desc employees_info;
