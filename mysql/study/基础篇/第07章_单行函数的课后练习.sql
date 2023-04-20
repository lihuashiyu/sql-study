#第07章_单行函数的课后练习


# 1. 显示系统时间(注：日期+时间)
select now(), sysdate(), current_timestamp(), localtime(), localtimestamp() from `dual`;

# 2. 查询员工号，姓名，工资，以及工资提高百分之 20% 后的结果（new salary）
select `employee_id`, `last_name`, `salary`, `salary` * 1.2 "new salary" from `employees`;

# 3. 将员工的姓名按首字母排序，并写出姓名的长度（length）
select `last_name`, length(`last_name`) "name_length" from `employees` order by `name_length` asc;

# 4. 查询员工 id, last_name, salary，并作为一个列输出，别名为 out_put
select concat(`employee_id`, ',', `last_name`, ',', `salary`) "out_put" from `employees`;

# 5.查询公司各员工工作的年数、工作的天数，并按工作年数的降序排序
select `employee_id`,
       datediff(curdate(), `hire_date`) / 365    "worked_years",
       datediff(curdate(), `hire_date`)          "worked_days",
       to_days(curdate()) - to_days(`hire_date`) "worked_days1"
from `employees`
order by `worked_years` desc;

# 6.查询员工姓名，hire_date, department_id，满足以下条件：
# 雇用时间在 1997 年之后，department_id 为 80 或 90 或 110, commission_pct 不为空
select `last_name`, `hire_date`, `department_id` from `employees`
where `department_id` in (80, 90, 110) and `commission_pct` is not null
  # and hire_date >= '1997-01-01';                                   # 存在着隐式转换
  # and date_format(hire_date,'%Y-%m-%d') >= '1997-01-01';           # 显式转换操作，格式化：日期---> 字符串
  # and date_format(hire_date,'%Y') >= '1997';                       # 显式转换操作，格式化
  and `hire_date` >= str_to_date('1997-01-01', '%Y-%m-%d');           # 显式转换操作，解析：字符串 ----> 日期

# 7.查询公司中入职超过 10000 天的员工姓名、入职时间
select `last_name`, `hire_date` from `employees` where datediff(curdate(), `hire_date`) >= 10000;

# 8.做一个查询，产生下面的结果
# <last_name> earns <salary> monthly but wants <salary*3>
select concat(`last_name`, ' earns ', truncate(`salary`, 0), ' monthly but wants ', truncate(`salary` * 3, 0)) as "dream salary"
from `employees`;

# 9.使用case-when，按照下面的条件：
/*
    job                  grade
    ad_pres              	a
    st_man               	b
    it_prog              	c
    sa_rep               	d
    st_clerk             	e
*/
select `last_name` as                  "last_name",
       `job_id`    as                  "job_id",
       case `job_id`
           when 'AD_PRES'  then 'A'
           when 'ST_MAN'   then 'B'
           when 'IT_PROG'  then 'C'
           when 'SA_REP'   then 'D'
           when 'ST_CLERK' then 'E'
       end "grade"
from `employees`;

select `last_name` as           "last_name",
       `job_id`    as           "job_id",
       case `job_id`
           when 'AD_PRES'  then 'A'
           when 'ST_MAN'   then 'B'
           when 'IT_PROG'  then 'C'
           when 'SA_REP'   then 'D'
           when 'ST_CLERK' then 'E'
           else 'undefined'
       end "grade"
from `employees`;
