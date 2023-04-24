# 第 11 章_数据处理之增删改

# 0. 储备工作
use at_guigu;
create table if not exists emp1
(
    id        int,
    name      varchar(15),
    hire_date date,
    salary    double(10, 2)
);

desc emp1;
select * from emp1;

# 1. 添加数据
# 方式1：一条一条的添加数据

# ① 没有指明添加的字段
insert into emp1 values (1, 'Tom', '2000-12-21', 3400);                      # 正确的
insert into emp1 values (2, 3400, '2000-12-21', 'Jerry');                    # 错误的

# ② 指明要添加的字段 （推荐）
insert into emp1(id, hire_date, salary, name) values (2, '1999-09-09', 4000, 'Jerry');
insert into emp1(id, salary, name) values (3, 4500, 'shk');                # 没有赋值的 hire_date 为 null

# ③ 同时插入多条记录 （推荐）
insert into emp1(id, name, salary) values (4, 'Jim', 5000), (5, '张俊杰', 5500);

# 方式2：将查询结果插入到表中
select * from emp1;
insert into emp1(id, name, salary, hire_date)

# 查询语句
select employee_id, last_name, salary, hire_date             # 查询的字段一定要与添加到的表的字段一一对应
from employees where department_id in (70, 60);

desc emp1;
desc employees;
# 说明：emp1 表中要添加数据的字段的长度不能低于 employees 表中查询的字段的长度。
# 如果 emp1 表中要添加数据的字段的长度低于 employees 表中查询的字段的长度的话，就有添加不成功的风险。

# 2. 更新数据（或修改数据）：可以实现批量修改数据的：update .... set .... where ...
update emp1 set hire_date = curdate() where id = 5;
select * from emp1;

# 同时修改一条数据的多个字段
update emp1 set hire_date = curdate(), salary = 6000 where id = 4;

# 题目：将表中姓名中包含字符a的提薪20%
update emp1 set salary = salary * 1.2 where name like '%a%';

# 修改数据时，是可能存在不成功的情况的。（可能是由于约束的影响造成的）
update employees set department_id = 10000 where employee_id = 102;

# 3. 删除数据：delete from .... where....
delete from emp1 where id = 1;

# 在删除数据时，也有可能因为约束的影响，导致删除失败
delete from departments where department_id = 50;
# 小结：DML 操作默认情况下，执行完以后都会自动提交数据，若希望不自动提交，则需使用 set autocommit = false

# 4. MySQL8 的新特性：计算列
use at_guigu;
create table test1
(
    a int,
    b int,
    c int generated always as (a + b) virtual                            # 字段 c 即为计算列
);

insert into test1(a, b) values (10, 20);
select * from test1;
update test1 set a = 100;

# 5.综合案例
# 1、创建数据库 test01_library
create database if not exists test01_library character set 'utf8';
use test01_library;

# 2、创建表 books，表结构如下：
create table if not exists books
(
    id      int,
    name    varchar(50),
    authors varchar(100),
    price   float,
    pubdate year,
    note    varchar(100),
    num     int
);

desc books;
select * from books;

# 3、向 books 表中插入记录
# 1）不指定字段名称，插入第一条记录
insert into books values (1, 'Tal of AAA', 'Dickes', 23, '1995', 'novel', 11);

# 2）指定所有字段名称，插入第二记录
insert into books(id, name, authors, price, pubdate, note, num)
values (2, 'EmmaT', 'Jane lura', 35, '1993', 'joke', 22);

# 3）同时插入多条记录（剩下的所有记录）
insert into books(id, name, authors, price, pubdate, note, num)
values (3, 'Story of Jane', 'Jane Tim', 40, 2001, 'novel', 0),
       (4, 'Lovey Day', 'George Byron', 20, 2005, 'novel', 30),
       (5, 'Old land', 'Honore Blade', 30, 2010, 'Law', 0),
       (6, 'The Battle', 'Upton Sara', 30, 1999, 'medicine', 40),
       (7, 'Rose Hood', 'Richard haggard', 28, 2008, 'cartoon', 28);

# 4、将小说类型(novel)的书的价格都增加 5。
update books set price = price + 5 where note = 'novel';

# 5、将名称为 EmmaT 的书的价格改为 40，并将说明改为 drama。
update books set price = 40, note  = 'drama' where name = 'EmmaT';

# 6、删除库存为 0 的记录。
delete from books where num = 0;

# 7、统计书名中包含 a 字母的书
select name from books where name like '%a%';

# 8、统计书名中包含 a 字母的书的数量和库存总量
select count(*), sum(num) from books where name like '%a%';

# 9、找出 "novel" 类型的书，按照价格降序排列
select name, note, price from books where note = 'novel' order by price desc;

# 10、查询图书信息，按照库存量降序排列，如果库存量相同的按照 note 升序排列
select * from books order by num desc, note asc;

# 11、按照 note 分类统计书的数量
select note, count(*) from books group by note;

# 12、按照 note 分类统计书的库存量，显示库存量超过 30 本的
select note, sum(num) from books group by note having sum(num) > 30;

# 13、查询所有图书，每页显示 5 本，显示第二页
select * from books limit 5, 5;

# 14、按照 note 分类统计书的库存量，显示库存量最多的
select note, sum(num) sum_num from books group by note order by sum_num desc limit 0, 1;

# 15、查询书名达到 10 个字符的书，不包括里面的空格
select char_length(replace(name, ' ', '')) from books;
select name from books where char_length(replace(name, ' ', '')) >= 10;

# 16、查询书名和类型，其中 note 值为 novel 显示小说，law 显示法律，medicine 显示医药，
# cartoon 显示卡通，joke 显示笑话
select name            "书名",
       note,
       case note
           when 'novel' then '小说'
           when 'law' then '法律'
           when 'medicine' then '医药'
           when 'cartoon' then '卡通'
           when 'joke' then '笑话'
           else '其他'
       end '类型'
from books;


# 17、查询书名、库存，其中 num 值超过 30 本的，显示滞销，大于 0 并低于 10 的，
#显示畅销，为 0 的显示需要无货
select name as         "书名",
       num  as         "库存",
       case
           when num > 30              then '滞销'
           when num > 0 and num < 10 then '畅销'
           when num = 0               then '无货'
           else '正常'
       end '显示状态'
from books;

# 18、统计每一种 note 的库存量，并合计总量
select ifnull(note, '合计库存总量') as note, sum(num) from books group by note with rollup;

# 19、统计每一种 note 的数量，并合计总量
select ifnull(note, '合计总量') as note, count(*) from books group by note with rollup;

# 20、统计库存量前三名的图书
select * from books order by num desc limit 0, 3;

# 21、找出最早出版的一本书
select * from books order by pubdate asc limit 0, 1;

# 22、找出 novel 中价格最高的一本书
select * from books where note = 'novel' order by price desc limit 0, 1;

# 23、找出书名中字数最多的一本书，不含空格
select * from books order by char_length(replace(name, ' ', '')) desc limit 0, 1;
