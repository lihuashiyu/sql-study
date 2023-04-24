# 第08章_聚合函数

# 1. 常见的几个聚合函数
# 1.1 avg / sum ：只适用于数值类型的字段（或变量）
select avg(salary), sum(salary), avg(salary) * 107 from employees;
select sum(last_name), avg(last_name), sum(hire_date) from employees;  # 操作没有意义

# 1.2 max / min :适用于数值类型、字符串类型、日期时间类型的字段（或变量）
select max(salary), min(salary) from employees;
select max(last_name), min(last_name), max(hire_date), min(hire_date) from employees;

# 1.3 count：
# ① 作用：计算指定字段在查询结构中出现的个数（不包含NULL值的）
select count(employee_id), count(salary), count(2 * salary), count(1), count(2), count(*) from employees;
select * from employees;

# 如果计算表中有多少条记录：方式1：count(*)，方式2：count(1)， 方式3：count(具体字段) : 不一定对！
# ② 注意：计算指定字段出现的个数时，是不计算NULL值的。
select count(commission_pct) from employees;
select commission_pct from employees where commission_pct is not null;

# ③ 公式：avg = sum / count
select avg(salary), sum(salary) / count(salary), avg(commission_pct),
       sum(commission_pct) / count(commission_pct), sum(commission_pct) / 107
from employees;

# 需求：查询公司中平均奖金率
select avg(commission_pct) from employees;                                 # 错误的
select sum(commission_pct) / count(ifnull(commission_pct, 0)), avg(ifnull(commission_pct, 0)) # 正确的
from employees;

# 如果使用的是 myisam 存储引擎，则三者效率相同，都是 o(1)
# 如果使用的是 innodb 存储引擎，则三者效率：count(*) = count(1) > count(字段)
# 其他：方差、标准差、中位数

# 2. group by 的使用
# 需求：查询各个部门的平均工资，最高工资
select department_id, avg(salary), sum(salary) from employees group by department_id;

# 需求：查询各个 job_id 的平均工资
select job_id, avg(salary) from employees group by job_id;

# 需求：查询各个 department_id, job_id 的平均工资
select department_id, job_id, avg(salary) from employees group by department_id, job_id;    # 方式1
select job_id, department_id, avg(salary) from employees group by job_id, department_id;    # 方式2
select department_id, job_id, avg(salary) from employees group by department_id;             # 错误的！

# 结论1：select 中出现的非组函数的字段必须声明在 group by 中，反之，group by 中声明的字段可以不出现在 select 中
# 结论2：group by 声明在 from 后面、where 后面，order by 前面、limit 前面
# 结论3：Mysql 中 group by 中使用 with rollup
select department_id, avg(salary) from employees group by department_id with rollup;

# 需求：查询各个部门的平均工资，按照平均工资升序排列
select department_id, avg(salary) avg_sal from employees group by department_id order by avg_sal asc;

# 说明：当使用 rollup 时，不能同时使用 order by 子句进行结果排序，即 rollup 和 order by 是互相排斥的
# 错误的：
select department_id, avg(salary) avg_sal
from employees
group by department_id
with rollup
order by avg_sal asc;

# 3. having 的使用 (作用：用来过滤数据的)
# 练习：查询各个部门中最高工资比 10000 高的部门信息
# 错误的写法：
select department_id, max(salary) from employees where max(salary) > 10000 group by department_id;

# 要求1：如果过滤条件中使用了聚合函数，则必须使用 having 来替换 where，否则，报错
# 要求2：having 必须声明在 group by 的后面
# 要求3：开发中，我们使用 having 的前提是 sql 中使用了 group by
# 正确的写法：
select department_id, max(salary) from employees group by department_id having max(salary) > 10000;

# 练习：查询部门 id 为 10, 20, 30, 40 这 4 个部门中最高工资比 10000 高的部门信息
# 方式1：推荐，执行效率高于方式 2.
select department_id, max(salary) from employees
where department_id in (10, 20, 30, 40) group by department_id having max(salary) > 10000;

# 方式2：
select department_id, max(salary) from employees group by department_id
having max(salary) > 10000 and department_id in (10, 20, 30, 40);
# 结论：当过滤条件中有聚合函数时，则此过滤条件必须声明在 having 中
#      当过滤条件中没有聚合函数时，则此过滤条件声明在 where 中或 having 中都可以，但建议大家声明在 where 中

/*
      where 与 having 的对比:
        1. 从适用范围上来讲，having 的适用范围更广
        2. 如果过滤条件中没有聚合函数：这种情况下，where 的执行效率要高于 having
*/

/*
    4.1 select 语句的完整结构：
        SQL92 语法：
            select ...., ...., ....              (存在聚合函数)
            from ..., ...., ....
            where                                多表的连接条件 and 不包含聚合函数的过滤条件
            group by ..., ....
            having                               包含聚合函数的过滤条件
            order by ...., ...(asc/desc )
            limit ..., ....

        SQL99 语法：
            select ...., ...., ....              (存在聚合函数)
            from ... (left/right) join .... on   多表的连接条件
            (left/right)join ... on ....
            where                                不包含聚合函数的过滤条件
            group by ..., ....
            having                               包含聚合函数的过滤条件
            order by ...., ...(asc/desc )
            limit ..., ....

    4.2 SQL 语句的执行过程：
        from ..., ... -> on -> (left/right  join) -> where -> group by -> having ->
        select -> distinct -> order by -> limit
*/
