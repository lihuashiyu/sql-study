# 第 12 章 MySQL 数据类型精讲
# 本章的内容测试建议使用 MySQL5.7进行测试。

# 1.关于属性：character set name
show variables like 'character_%';

# 创建数据库时指名字符集
create database if not exists dbtest12 character set 'utf8';
show create database dbtest12;

# 创建表的时候，指名表的字符集
create table temp (id int) character set 'utf8';
show create table temp;

# 创建表，指名表中的字段时，可以指定字段的字符集
create table temp1 (id int, name varchar(15) character set 'gbk');
show create table temp1;

# 2.整型数据类型
use dbtest12;
create table test_int1(f1 tinyint, f2 smallint, f3 mediumint, f4 integer, f5 bigint);
desc test_int1;
insert into test_int1(f1) values (12), (-12), (-128), (127);
select * from test_int1;
insert into test_int1(f1) values (128);                          # Out of range value for column 'f1' at row 1

# ① 显示宽度为 5,当 insert 的值不足 5 位时，使用 0 填充L；② 当使用 zerofill 时，自动会添加 unsigned
create table test_int2(f1 int, f2 int(5), f3 int(5) zerofill);
insert into test_int2(f1, f2) values (123, 123), (123456, 123456);

select * from test_int2;
insert into test_int2(f3) values (123), (123456);
show create table test_int2;

create table test_int3 (f1 int unsigned);
desc test_int3;
insert into test_int3 values (2412321);
insert into test_int3 values (4294967296);               # Out of range value for column 'f1' at row 1

# 3.浮点类型
create table test_double1 (f1 float, f2 float(5, 2), f3 double, f4 double(5, 2));
desc test_double1;

insert into test_double1(f1, f2) values (123.45, 123.45);
select * from test_double1;

insert into test_double1(f3, f4) values (123.45, 123.456);     # 存在四舍五入
insert into test_double1(f3, f4) values (123.45, 1234.456);    # Out of range value for column 'f4' at row 1
insert into test_double1(f3, f4) values (123.45, 999.995);     # Out of range value for column 'f4' at row 1

# 测试 float 和 double 的精度问题
create table test_double2 (f1 double);
insert into test_double2 values (0.47), (0.44), (0.19);
select sum(f1) from test_double2;
select sum(f1) = 1.1, 1.1 = 1.1 from test_double2;

# 4. 定点数类型：存在四色五入
create table test_decimal1 (f1 decimal, f2 decimal(5, 2));
desc test_decimal1;

insert into test_decimal1(f1) values (123), (123.45);
select * from test_decimal1;

insert into test_decimal1(f2) values (999.99);
insert into test_decimal1(f2) values (67.567);

insert into test_decimal1(f2) values (1267.567);                 # Out of range value for column 'f2' at row 1
insert into test_decimal1(f2) values (999.995);                  # Out of range value for column 'f2' at row 1
alter table test_double2 modify f1 decimal(5, 2);                # 演示 decimal 替换 double，体现精度

desc test_double2;
select sum(f1) from test_double2;
select sum(f1) = 1.1, 1.1 = 1.1 from test_double2;

# 5. 位类型：bit
create table test_bit1 (f1 bit, f2 bit(5), f3 bit(64));
desc test_bit1;

insert into test_bit1(f1) values (0), (1);
select * from test_bit1;

insert into test_bit1(f1) values (2);                            # Data too long for column 'f1' at row 1
insert into test_bit1(f2) values (31);
insert into test_bit1(f2) values (32);                           # Data too long for column 'f2' at row 1

select bin(f1), bin(f2), hex(f1), hex(f2) from test_bit1;
select f1 + 0, f2 + 0 from test_bit1;                          # 此时 +0 以后，可以以十进制的方式显示数据

# 6.1 year 类型
create table test_year (f1 year, f2 year(4));
desc test_year;

insert into test_year(f1) values ('2021'), (2022);
select * from test_year;

insert into test_year(f1) values ('2155');
insert into test_year(f1) values ('2156');                       # Out of range value for column 'f1' at row 1
insert into test_year(f1) values ('69'), ('70');
insert into test_year(f1) values (0), ('00');

# 6.2 date 类型
create table test_date1 (f1 date);
desc test_date1;

insert into test_date1 values ('2020-10-01'), ('20201001'), (20201001);
insert into test_date1
values ('00-01-01'), ('000101'), ('69-10-01'), ('691001'), ('70-01-01'), ('700101'), ('99-01-01'), ('990101');

insert into test_date1 values (000301), (690301), (700301), (990301);   # 存在隐式转换
insert into test_date1 values (curdate()), (current_date()), (now());

select * from test_date1;

# 6.3 time 类型
create table test_time1 (f1 time);
desc test_time1;

insert into test_time1 values ('2 12:30:29'), ('12:35:29'), ('12:40'), ('2 12:40'), ('1 05'), ('45');
insert into test_time1 values ('123520'), (124011), (1210);
insert into test_time1 values (now()), (current_time()), (curtime());

select * from test_time1;

# 6.4 datetime 类型
create table test_datetime1 (dt datetime);
insert into test_datetime1 values ('2021-01-01 06:50:30'), ('20210101065030');

insert into test_datetime1
values ('99-01-01 00:00:00'), ('990101000000'), ('20-01-01 00:00:00'), ('200101000000');

insert into test_datetime1
values (20200101000000), (200101000000), (19990101000000), (990101000000);

insert into test_datetime1 values (current_timestamp()), (now()), (sysdate());
select * from test_datetime1;

# 6.5 timestamp 类型
create table test_timestamp1 (ts timestamp);

insert into test_timestamp1
values ('1999-01-01 03:04:50'), ('19990101030405'), ('99-01-01 03:04:05'), ('990101030405');
insert into test_timestamp1 values ('2020@01@01@00@00@00'), ('20@01@01@00@00@00');
insert into test_timestamp1 values (current_timestamp()), (now());
insert into test_timestamp1 values ('2038-01-20 03:14:07');        # Incorrect datetime value
select * from test_timestamp1;

# 对比 datetime 和 timestamp
create table temp_time (d1 datetime, d2 timestamp);
insert into temp_time values ('2021-9-2 14:45:52', '2021-9-2 14:45:52');
insert into temp_time values (now(), now());
select * from temp_time;

set time_zone = '+9:00';                                             # 修改当前的时区
select * from temp_time;

# 7.1 char 类型
create table test_char1 (c1 char, c2 char(5));
desc test_char1;

insert into test_char1(c1) values ('a');
insert into test_char1(c1) values ('ab');                        # Data too long for column 'c1' at row 1
insert into test_char1(c2) values ('ab');
insert into test_char1(c2) values ('hello');
insert into test_char1(c2) values ('尚');
insert into test_char1(c2) values ('硅谷');
insert into test_char1(c2) values ('尚硅谷教育');
insert into test_char1(c2) values ('尚硅谷IT教育');              # Data too long for column 'c2' at row 1

select * from test_char1;
select concat(c2, '***') from test_char1;

insert into test_char1(c2) values ('ab  ');
select char_length(c2) from test_char1;

# 7.2 varchar 类型
create table test_varchar1(name varchar);                       # 错误
# Column length too big for column 'name' (max = 21845); use BLOB or TEXT instead
create table test_varchar2 (name varchar(65535));
create table test_varchar3 (name varchar(5));

insert into test_varchar3 values ('尚硅谷'), ('尚硅谷教育');
insert into test_varchar3 values ('尚硅谷IT教育');            # Data too long for column 'NAME' at row 1

# 7.3 text 类型
create table test_text (tx text);
insert into test_text values ('atguigu   ');
select char_length(tx) from test_text;                           # 10

# 8. enum 类型
create table test_enum (season enum ('春','夏','秋','冬','unknow'));
insert into test_enum values ('春'), ('秋');
select * from test_enum;

insert into test_enum values ('春,秋');                    # Data truncated for column 'season' at row 1
insert into test_enum values ('人');                       # Data truncated for column 'season' at row 1
insert into test_enum values ('unknow');
insert into test_enum values ('UNKNOW');                           # 忽略大小写的
insert into test_enum values (1), ('3');                           # 可以使用索引进行枚举元素的调用
insert into test_enum values (null);                               # 没有限制非空的情况下，可以添加 null 值

# 9. set 类型
create table test_set (s set ('A', 'B', 'C'));
insert into test_set (s) values ('A'), ('A,B');
insert into test_set (s) values ('A,B,C,A');           # 插入重复的 set 类型成员时，MySQL 会自动删除重复的成员
insert into test_set (s) values ('A,B,C,D'); # 向 set 类型的字段插入 set 成员中不存在的值时，MySQL 会抛出错误
select * from test_set;

create table temp_mul(gender enum ('男','女'), hobby set ('吃饭','睡觉','打豆豆','写代码'));
insert into temp_mul values ('男', '睡觉,打豆豆');
select * from temp_mul;
insert into temp_mul values ('男,女', '睡觉,打豆豆');           # Data truncated for column 'gender' at row 1

# 10.1 binary 与 varbinary 类型
create table test_binary1
(
    f1 binary,
    f2 binary(3),
    # f3 varbinary,
    f4 varbinary(10)
);

desc test_binary1;
insert into test_binary1(f1, f2) values ('a', 'abc');
select * from test_binary1;

insert into test_binary1(f1) values ('ab');                      # Data too long for column 'f1' at row 1
insert into test_binary1(f2, f4) values ('ab', 'ab');
select length(f2), length(f4) from test_binary1;

# 10.2 blob 类型
create table test_blob1 (id int, img mediumblob);
insert into test_blob1(id) values (1001);
select * from test_blob1;

# 11. json 类型
create table test_json (js json);

insert into test_json (js)
values ('
{
  "name": "songhk",
  "age": 18,
  "address":
  {
    "province": "beijing",
    "city": "beijing"
  }
}');

select * from test_json;
select js -> '$.name'             as name,
       js -> '$.age'              as age,
       js -> '$.address.province' as province,
       js -> '$.address.city'     as city
from test_json;
