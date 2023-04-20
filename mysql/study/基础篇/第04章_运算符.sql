# 第04章_运算符
#1. 算术运算符： +  -  *  /  div  % mod

select 100, 100 + 0, 100 - 0, 100 + 50, 100 + 50 * 30, 100 + 35.5, 100 - 35.5 from `dual`;

# 在SQL中，+没有连接的作用，就表示加法运算。此时，会将字符串转换为数值（隐式转换）
select 100 + '1' from `dual`;                              # 在Java语言中，结果是：1001。
select 100 + 'a' from `dual`;                              # 此时将'a'看做0处理
select 100 + null from `dual`;                             # null值参与运算，结果为null

select 100,
       100 * 1,
       100 * 1.0,
       100 / 1.0,
       100 / 2,
       100 + 2 * 5 / 2,
       100 / 3,
       100 div 0 # 分母如果为0，则结果为null
from `dual`;

# 取模运算： % mod
select 12 % 3, 12 % 5, 12 mod -5, -12 % 5, -12 % -5 from `dual`;

#练习：查询员工id为偶数的员工信息
select `employee_id`, `last_name`, `salary` from `employees` where `employee_id` % 2 = 0;

# 2. 比较运算符
# 2.1 =  <=>  <> !=  <  <=  >  >=

# = 的使用
select 1 = 2, 1 != 2, 1 = '1', 1 = 'a', 0 = 'a' from `dual`;    # 字符串存在隐式转换。如果转换数值不成功，则看做0
select 'a' = 'a', 'ab' = 'ab', 'a' = 'b' from `dual`;           # 两边都是字符串的话，则按照ANSI的比较规则进行比较。

select 1 = null, null = null from `dual`;                  # 只要有null参与判断，结果就为null

select `last_name`, `salary`, `commission_pct` from `employees`
# where salary = 6000;
where `commission_pct` = null; # 此时执行，不会有任何的结果

# <=> ：安全等于。 记忆技巧：为NULL而生。
select 1 <=> 2, 1 <=> '1', 1 <=> 'a', 0 <=> 'a' from `dual`;
select 1 <=> null, null <=> null from `dual`;

# 练习：查询表中commission_pct为null的数据有哪些
select `last_name`, `salary`, `commission_pct` from `employees` where `commission_pct` <=> null;

select 3 <> 2, '4' <> null, '' != null, null != null from `dual`;

# 2.2
# ① IS NULL \ IS NOT NULL \ ISNULL
#练习：查询表中commission_pct为null的数据有哪些
select `last_name`, `salary`, `commission_pct` from `employees` where `commission_pct` is null;
# 或
select `last_name`, `salary`, `commission_pct` from `employees` where isnull(`commission_pct`);

# 练习：查询表中commission_pct不为null的数据有哪些
select `last_name`, `salary`, `commission_pct` from `employees` where `commission_pct` is not null;
# 或
select `last_name`, `salary`, `commission_pct` from `employees` where not `commission_pct` <=> null;

# ② LEAST() \ GREATEST
select least('g', 'b', 't', 'm'), greatest('g', 'b', 't', 'm') from `dual`;

select least(`first_name`, `last_name`), least(length(`first_name`), length(`last_name`)) from `employees`;

# ③ BETWEEN 条件下界1 AND 条件上界2  （查询条件1和条件2范围内的数据，包含边界）
# 查询工资在6000 到 8000的员工信息
select `employee_id`, `last_name`, `salary` from `employees`
     #where salary between 6000 and 8000;
where `salary` >= 6000 && `salary` <= 8000;

#交换6000 和 8000之后，查询不到数据
select `employee_id`, `last_name`, `salary` from `employees` where `salary` between 8000 and 6000;

#查询工资不在6000 到 8000的员工信息
select `employee_id`, `last_name`, `salary` from `employees` where `salary` not between 6000 and 8000;
# where salary < 6000 or salary > 8000;

# ④ in (set)\ not in (set)
# 练习：查询部门为10,20,30部门的员工信息
select `last_name`, `salary`, `department_id` from `employees`
     #where department_id = 10 or department_id = 20 or department_id = 30;
where `department_id` in (10, 20, 30);

#练习：查询工资不是6000,7000,8000的员工信息
select `last_name`, `salary`, `department_id` from `employees` where `salary` not in (6000, 7000, 8000);

# ⑤ LIKE :模糊查询
# % : 代表不确定个数的字符 （0个，1个，或多个）

# 练习：查询last_name中包含字符'a'的员工信息
select `last_name` from `employees` where `last_name` like '%a%';

# 练习：查询last_name中以字符'a'开头的员工信息
select `last_name` from `employees` where `last_name` like 'a%';

# 练习：查询last_name中包含字符'a'且包含字符'e'的员工信息
# 写法1：
select `last_name` from `employees` where `last_name` like '%a%' and `last_name` like '%e%';
# 写法2：
select `last_name` from `employees` where `last_name` like '%a%e%' or `last_name` like '%e%a%';

# _ ：代表一个不确定的字符

# 练习：查询第3个字符是'a'的员工信息
select `last_name` from `employees` where `last_name` like '__a%';

# 练习：查询第2个字符是_且第3个字符是'a'的员工信息
# 需要使用转义字符: \
select `last_name` from `employees` where `last_name` like '_\_a%';

# 或者  (了解)
select `last_name` from `employees` where `last_name` like '_$_a%' escape '$';

#⑥ REGEXP \ RLIKE :正则表达式
select 'shkstart' regexp '^shk', 'shkstart' regexp 't$', 'shkstart' regexp 'hk' from `dual`;
select 'atguigu' regexp 'gu.gu', 'atguigu' regexp '[ab]' from `dual`;

# 3. 逻辑运算符： OR ||  AND && NOT ! XOR
# or  and 
select `last_name`, `salary`, `department_id` from `employees`
     # where department_id = 10 or department_id = 20;
     # where department_id = 10 and department_id = 20;
where `department_id` = 50 and `salary` > 6000;

# not 
select `last_name`, `salary`, `department_id` from `employees`
     #where salary not between 6000 and 8000;
     #where commission_pct is not null;
where not `commission_pct` <=> null;

# XOR :追求的"异"
select `last_name`, `salary`, `department_id` from `employees` where `department_id` = 50 xor `salary` > 6000;

# 注意：AND的优先级高于OR

# 4. 位运算符： & |  ^  ~  >>   <<
select 12 & 5, 12 | 5, 12 ^ 5 from `dual`;
select 10 & ~1 from `dual`;

# 在一定范围内满足：每向左移动1位，相当于乘以2；每向右移动一位，相当于除以2。
select 4 << 1, 8 >> 1 from `dual`;

