# 第 06 章_多表查询

/*
    select ...,....,....
    from ....
    where .... and / or / not....
    order by .... (asc/desc),....,...
    limit ...,...
*/

# 1. 熟悉常见的几个表
desc `employees`;
desc `departments`;
desc `locations`;

# 查询员工名为 'Abel' 的人在哪个城市工作？
select * from `employees` where `last_name` = 'Abel';
select * from `departments` where `department_id` = 80;
select * from `locations` where `location_id` = 2500;

# 2. 出现笛卡尔积的错误
# 错误的原因：缺少了多表的连接条件，错误的实现方式：每个员工都与每个部门匹配了一遍。
select `employee_id`, `department_name` from `employees`, `departments`;

# 查询出 2889 条记录
# 错误的方式
select `employee_id`, `department_name` from `employees` cross join `departments`;  # 查询出 2889 条记录
select * from `employees`;                                                     # 107条记录
select 2889 / 107 from `dual`;
select * from `departments`;
# 27 条记录


# 3. 多表查询的正确方式：需要有连接条件
select `employee_id`, `department_name`  from `employees`, `departments`
where `employees`.`department_id` = `departments`.`department_id`;             # 两个表的连接条件

# 4. 如果查询语句中出现了多个表中都存在的字段，则必须指明此字段所在的表。
select `employees`.`employee_id`, `departments`.`department_name`, `employees`.`department_id`
from `employees`, `departments`
where `employees`.`department_id` = `departments`.`department_id`;
# 建议：从 sql 优化的角度，建议多表查询时，每个字段前都指明其所在的表。

# 5. 可以给表起别名，在 select 和 where 中使用表的别名。
select `emp`.`employee_id`, `dept`.`department_name`, `emp`.`department_id`
from `employees` `emp`, `departments` `dept`
where `emp`.`department_id` = `dept`.`department_id`;

# 如果给表起了别名，一旦在 select 或 where 中使用表名的话，则必须使用表的别名，而不能再使用表的原名。
# 如下的操作是错误的：
select `emp`.`employee_id`, `departments`.`department_name`, `emp`.`department_id`
from `employees` `emp`, `departments` `dept`
where `emp`.`department_id` = `departments`.`department_id`;

# 6. 结论：如果有 n 个表实现多表的查询，则需要至少 n-1 个连接条件
# 练习：查询员工的 employee_id, last_name, department_name, city
select `e`.`employee_id`,
       `e`.`last_name`,
       `d`.`department_name`,
       `l`.`city`,
       `e`.`department_id`,
       `l`.`location_id`
from `employees` `e`,
     `departments` `d`,
     `locations` `l`
where `e`.`department_id` = `d`.`department_id` and `d`.`location_id` = `l`.`location_id`;

/*
    演绎式：提出问题1 ---> 解决问题1 ----> 提出问题2 ---> 解决问题2 ....
    归纳式：总--分
*/


# 7. 多表查询的分类
/*
    角度1：等值连接  vs  非等值连接
    角度2：自连接    vs  非自连接
    角度3：内连接    vs  外连接
*/

# 7.1 等值连接  vs  非等值连接

# 非等值连接的例子：
select * from `job_grades`;

select `e`.`last_name`, `e`.`salary`, `j`.`grade_level`
from `employees` `e`, `job_grades` `j`
# where e.`salary` between j.`lowest_sal` and j.`highest_sal`;
where `e`.`salary` >= `j`.`lowest_sal` and `e`.`salary` <= `j`.`highest_sal`;

# 7.2 自连接  vs  非自连接
select * from `employees`;

# 自连接的例子：
# 练习：查询员工id,员工姓名及其管理者的id和姓名
select `emp`.`employee_id`, `emp`.`last_name`, `mgr`.`employee_id`, `mgr`.`last_name`
from `employees` `emp`, `employees` `mgr`
where `emp`.`manager_id` = `mgr`.`employee_id`;


# 7.3 内连接  vs  外连接
# 内连接：合并具有同一列的两个以上的表的行, 结果集中不包含一个表与另一个表不匹配的行
select `employee_id`, `department_name`
from `employees` `e`, `departments` `d`
where `e`.`department_id` = `d`.`department_id`;                               # 只有 106 条记录

# 外连接：合并具有同一列的两个以上的表的行, 结果集中除了包含一个表与另一个表匹配的行之外，
#         还查询到了左表 或 右表中不匹配的行。

# 外连接的分类：左外连接、右外连接、满外连接

# 左外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回左表中不满足条件的行，这种连接称为左外连接。
# 右外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回右表中不满足条件的行，这种连接称为右外连接。

# 练习：查询所有的员工的 last_name, department_name 信息
select `employee_id`, `department_name`
from `employees` `e`, `departments` `d`
where `e`.`department_id` = `d`.`department_id`;                               # 需要使用左外连接
select * from `employees`, `departments` where `employees`.`department_id` = `departments`.`department_id`;

# SQL92 语法实现内连接：见上，略
# SQL92 语法实现外连接：使用 +  ---------- MySQL 不支持 SQL92 语法中外连接的写法！
# 不支持：
select `employee_id`, `department_name`
from `employees` `e`, `departments` `d`
where `e`.`department_id` = `d`.`department_id`(+);

# sql99 语法中使用 join ...on 的方式实现多表的查询。这种方式也能解决外连接的问题，Mysql 支持此种方式
# sql99 语法如何实现多表的查询

# SQL99 语法实现内连接：
select `last_name`, `department_name`
from `employees` `e` inner join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

select `last_name`, `department_name`, `city`
from `employees` `e` join `departments` `d` on `e`.`department_id` = `d`.`department_id`
         join `locations` `l` on `d`.`location_id` = `l`.`location_id`;

# SQL99 语法实现外连接：
# 练习：查询所有的员工的last_name,department_name信息
# 左外连接：
select `last_name`, `department_name`
from `employees` `e` left join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

# 右外连接：
select `last_name`, `department_name`
from `employees` `e` right outer join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

# 满外连接：Mysql 不支持 full outer join
select `last_name`, `department_name` from `employees` `e` full outer join departments d on e.`department_id` = d.`department_id`;


# 8. union  和 union all的使用：union，会执行去重操作；union all，不会执行去重操作
# 结论：如果明确知道合并数据后的结果数据不存在重复数据，或者不需要去除重复的数据，
#         则尽量使用 union all 语句，以提高数据查询的效率。

# 9. 7 种 join 的实现：
# 中图：内连接
select `employee_id`, `department_name`
from `employees` `e` join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

# 左上图：左外连接
select `employee_id`, `department_name`
from `employees` `e` left join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

# 右上图：右外连接
select `employee_id`, `department_name`
from `employees` `e` right join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

# 左中图：
select `employee_id`, `department_name`
from `employees` `e` left join `departments` `d` on `e`.`department_id` = `d`.`department_id`
where `d`.`department_id` is null;

# 右中图：
select `employee_id`, `department_name`
from `employees` `e` right join `departments` `d` on `e`.`department_id` = `d`.`department_id`
where `e`.`department_id` is null;

# 左下图：满外连接
# 方式1：左上图 union all 右中图
select `employee_id`, `department_name`
from `employees` `e` left join `departments` `d` on `e`.`department_id` = `d`.`department_id`
union all
select `employee_id`, `department_name`
from `employees` `e` right join `departments` `d` on `e`.`department_id` = `d`.`department_id`
where `e`.`department_id` is null;

# 方式2：左中图 union all 右上图
select `employee_id`, `department_name`
from `employees` `e` left join `departments` `d` on `e`.`department_id` = `d`.`department_id`
where `d`.`department_id` is null
union all
select `employee_id`, `department_name`
from `employees` `e` right join `departments` `d` on `e`.`department_id` = `d`.`department_id`;

# 右下图：左中图  union all 右中图
select `employee_id`, `department_name`
from `employees` `e` left join `departments` `d` on `e`.`department_id` = `d`.`department_id`
where `d`.`department_id` is null
union all
select `employee_id`, `department_name`
from `employees` `e` right join `departments` `d` on `e`.`department_id` = `d`.`department_id`
where `e`.`department_id` is null;


# 10. SQL99 语法的新特性1：自然连接
select `employee_id`, `last_name`, `department_name`
from `employees` `e` join `departments` `d` on `e`.`department_id` = `d`.`department_id` and `e`.`manager_id` = `d`.`manager_id`;

# natural join : 它会帮你自动查询两张连接表中`所有相同的字段`，然后进行`等值连接`。
select `employee_id`, `last_name`, `department_name` from `employees` `e` natural join `departments` `d`;

# 11. SQL99 语法的新特性2：using
select `employee_id`, `last_name`, `department_name`from `employees` `e` join `departments` `d` on `e`.`department_id` = `d`.`department_id`;
select `employee_id`, `last_name`, `department_name`from `employees` join `departments` using (`department_id`);


# 拓展：
select `last_name`, `job_title`, `department_name`
from `employees`
         inner join `departments`
         inner join `jobs` on `employees`.`department_id` = `departments`.`department_id` and
                              `employees`.`job_id` = `jobs`.`job_id`;