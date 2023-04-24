# 第 07 章_单行函数

# 1.数值函数
# 基本的操作
select abs(-123), abs(32),
       sign(-23), sign(43),
       pi(),
       ceil(32.32), ceiling(-43.23),
       floor(32.32), floor(-43.23),
       mod(12, 5), 12 mod 5, 12 % 5
from dual;

# 取随机数
select rand(), rand(), rand(10), rand(10), rand(-1), rand(-1) from dual;

# 四舍五入，截断操作
select round(123.556), round(123.456, 0), round(123.456, 1),
       round(123.456, 2), round(123.456, -1), round(153.456, -2)
from dual;

select truncate(123.456, 0), truncate(123.496, 1), truncate(129.45, -1) from dual;

# 单行函数可以嵌套
select truncate(round(123.456, 2), 0) from dual;

# 角度与弧度的互换
select radians(30), radians(45), radians(60), radians(90), degrees(2 * pi()), degrees(radians(60)) from dual;

# 三角函数
select sin(radians(30)), degrees(asin(1)), tan(radians(45)), degrees(atan(1)) from dual;

# 指数和对数
select pow(2, 5), power(2, 4), exp(2) from dual;
select ln(exp(2)), log(exp(2)), log10(10), log2(4) from dual;

# 进制间的转换: 二进制、十六进制、八进制、准换：10，由十进制转换为八进制
select bin(10), hex(10), oct(10), conv(10, 10, 8) from dual;


# 2. 字符串函数
select ascii('Abcdfsf'), char_length('hello'), char_length('我们'), length('hello'), length('我们') from dual;

# xxx worked for yyy
select concat(emp.last_name, ' worked for ', mgr.last_name) "details"
from employees emp join employees mgr
where emp.manager_id = mgr.employee_id;

select concat_ws('-', 'hello', 'world', 'hello', 'beijing') from dual;

# 字符串的索引是从 1 开始的！
select insert('helloworld', 2, 3, 'aaaaa'), replace('hello', 'lol', 'mmm') from dual;
select upper('HelLo'), lower('HelLo') from dual;

select last_name, salary from employees where lower(last_name) = 'King';
select left('hello', 2), right('hello', 3), right('hello', 13) from dual;

# lpad：实现右对齐效果；rpad：实现左对齐效果
select employee_id, last_name, lpad(salary, 10, ' ') from employees;

select concat('---', ltrim('    h  el  lo   '), '***'), trim('oo' from 'ooheollo') from dual;

select repeat('hello', 4), length(space(5)), strcmp('abc', 'abe') from dual;

select substr('hello', 2, 2), locate('lll', 'hello') from dual;

select elt(2, 'a', 'b', 'c', 'd'),
       field('mm', 'gg', 'jj', 'mm', 'dd', 'mm'),
       find_in_set('mm', 'gg,mm,jj,dd,mm,gg')
from dual;

select employee_id, nullif(length(first_name), length(last_name)) "compare" from employees;


# 3. 日期和时间函数
# 3.1  获取日期、时间
select curdate(), current_date(), curtime(), now(), sysdate(), utc_date(), utc_time() from dual;
select curdate(), curdate() + 0, curtime() + 0, now() + 0 from dual;

# 3.2 日期与时间戳的转换
select unix_timestamp(),
       unix_timestamp('2021-11-21 12:12:32'),
       from_unixtime(1635173853),
       from_unixtime(1633061552)
from dual;

# 3.3 获取月份、星期、星期数、天数等函数
select year(curdate()),
       month(curdate()),
       day(curdate()),
       hour(curtime()),
       minute(now()),
       second(sysdate())
from dual;

select monthname('2021-10-26'),
       dayname('2021-10-26'),
       weekday('2021-10-26'),
       quarter(curdate()),
       week(curdate()),
       dayofyear(now()),
       dayofmonth(now()),
       dayofweek(now())
from dual;

# 3.4 日期的操作函数
select extract(second from now()),
       extract(day from now()),
       extract(hour_minute from now()),
       extract(quarter from '2021-05-12')
from dual;

# 3.5 时间和秒钟转换的函数
select time_to_sec(curtime()), sec_to_time(55932) from dual;

#3.6 计算日期和时间的函数
select now(),
       date_add(now(), interval 1 year),
       date_add(now(), interval -1 year),
       date_sub(now(), interval 1 year)
from dual;

select date_add(now(), interval 1 day)                               as col1,
       date_add('2021-10-21 23:32:12', interval 1 second)            as col2,
       adddate('2021-10-21 23:32:12', interval 1 second)             as col3,
       date_add('2021-10-21 23:32:12', interval '1_1' minute_second) as col4,
       date_add(now(), interval -1 year)                             as col5, # 可以是负数
       date_add(now(), interval '1_1' year_month)                    as col6  # 需要单引号
from dual;

select addtime(now(), 20)                     as c01,
       subtime(now(), 30)                     as c02,
       subtime(now(), '1:1:3')                as c03,
       datediff(now(), '2021-10-01')          as c04,
       timediff(now(), '2021-10-25 22:10:10') as c05,
       from_days(366)                         as c06,
       to_days('0000-12-25')                  as c07,
       last_day(now())                        as c08,
       makedate(year(now()), 32)              as c09,
       maketime(10, 21, 23)                   as c10,
       period_add(20200101010101, 10)         as c11
from dual;

# 3.7 日期的格式化与解析
# 格式化：日期 ---> 字符串
# 解析：  字符串 ----> 日期
# 此时我们谈的是日期的显式格式化和解析
# 之前，我们接触过隐式的格式化或解析
select * from employees where hire_date = '1993-01-13';

# 格式化：
select date_format(curdate(), '%Y-%M-%D')                  as c1,
       date_format(now(), '%Y-%m-%d')                      as c2,
       time_format(curtime(), '%h:%i:%S')                  as c3,
       date_format(now(), '%Y-%M-%D %h:%i:%S %W %w %T %r') as c4
from dual;

# 解析：格式化的逆过程
select str_to_date('2021-October-25th 11:37:30 Monday 1', '%Y-%M-%D %h:%i:%S %W %w') from dual;
select get_format(date, 'USA') from dual;
select date_format(curdate(), get_format(date, 'USA')) from dual;

# 4.流程控制函数
# 4.1 if(value, value1, value2)
select last_name, salary, if(salary >= 6000, '高工资', '低工资') "details" from employees;

select last_name, commission_pct,
       if(commission_pct is not null, commission_pct, 0)                       "details",
       salary * 12 * (1 + if(commission_pct is not null, commission_pct, 0)) "annual_sal"
from employees;

# 4.2 ifnull(value1, value2)：看做是if(value, value1, value2)的特殊情况
select last_name, commission_pct, ifnull(commission_pct, 0) "details" from employees;

# 4.3 case when ... then ...when ... then ... else ... end 类似于 java 的 if ... else if ... else if ... else
select last_name, salary,
       case
           when salary >= 15000 then '白骨精'
           when salary >= 10000 then '潜力股'
           when salary >= 8000  then '小屌丝'
           else '草根'
       end
      "details", department_id
from employees;

select last_name, salary,
       case
           when salary >= 15000 then '白骨精'
           when salary >= 10000 then '潜力股'
           when salary >= 8000  then '小屌丝'
       end
      "details"
from employees;

# 4.4 case ... when ... then ... when ... then ... else ... end 类似于 java 的 switch ... case...
/*
    练习 1：
        查询部门号为 10,20, 30 的员工信息,
        若部门号为 10, 则打印其工资的 1.1 倍,
            20, 则打印其工资的 1.2 倍,
            30,打印其工资的 1.3 倍数,
            其他部门,打印其工资的 1.4 倍数
*/
select employee_id, last_name, department_id, salary,
       case department_id
           when 10 then salary * 1.1
           when 20 then salary * 1.2
           when 30 then salary * 1.3
           else salary * 1.4
       end
      "details"
from employees;

/*
    练习2
        查询部门号为 10,20, 30 的员工信息,
        若部门号为 10, 则打印其工资的 1.1 倍,
        20 号部门, 则打印其工资的 1.2 倍,
        30 号部门打印其工资的 1.3 倍数
*/
select employee_id, last_name, department_id, salary,
       case department_id
           when 10 then salary * 1.1
           when 20 then salary * 1.2
           when 30 then salary * 1.3
       end
       "details"
from employees where department_id in (10, 20, 30);


# 5. 加密与解密的函数
# password()、encode()、decode() 在 Mysql8.0 中弃用。
# select password('mysql') from 'dual';
select md5('mysql'), sha('mysql'), md5(md5('mysql')) from dual;
# select encode('atguigu', 'mysql'), decode(encode('atguigu', 'mysql'), 'mysql') from dual;


# 6. MySQL 信息函数
select version(), connection_id(), database(), schema(), user(),
       current_user(), charset('尚硅谷'), collation('尚硅谷')
from dual;


# 7. 其他函数
# 如果n的值小于或者等于0，则只保留整数部分
select format(123.125, 2), format(123.125, 0), format(123.125, -2) from dual;
select conv(16, 10, 2), conv(8888, 10, 16), conv(null, 10, 2) from dual;

# 以 "192.168.1.100" 为例，计算方式为 192 乘以 256 的 3 次方，加上 168 乘以 256 的 2 次方，
# 加上 1 乘以 256，再加上100
select inet_aton('192.168.1.100'), inet_ntoa(3232235876) from dual;

# benchmark() 用于测试表达式的执行效率
select benchmark(100000, md5('mysql')) from dual;

# convert()：可以实现字符集的转换
select charset('atguigu'), charset(convert('atguigu' using 'gbk')) from dual;
