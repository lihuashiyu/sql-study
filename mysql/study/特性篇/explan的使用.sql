
-- 1. table：表名
explain select * from s1;                                            -- 查询的每一行记录都对应着一个单表
explain select * from s1 inner join s2;                              -- s1:驱动表  s2:被驱动表
select * from s1 where key1 = 'a';                                   


-- 2. id：在一个大的查询语句中每个 select 关键字都对应一个唯一的 id
select * from s1 inner join s2 on s1.key1 = s2.key1 where s1.common_field = 'a';
select * from s1  where key1 in (select key3 from s2);
select * from s1 union select * from s2;

explain select * from s1 where key1 = 'a';
explain select * from s1 inner join s2;
explain select * from s1 where key1 in (select key1 from s2) or key3 = 'a';
 
-- 查询优化器可能对涉及子查询的查询语句进行重写,转变为多表查询的操作
explain select * from s1 where key1 in (select key2 from s2 where common_field = 'a');
explain select * from s1 union select * from s2;                     -- union 去重
explain select * from s1  union all select * from s2;


-- 3. select_type：select 关键字对应的那个查询的类型,确定小查询在整个大查询中扮演了一个什么角色
explain select * from s1;                                            -- 查询语句中不包含 `union` 或者子查询的查询都算作是 `simple` 类型
explain select * from s1 inner join s2;                              -- 连接查询也算是 `simple` 类型
-- 对于包含 `union` 或者 `union all` 或者子查询的大查询来说，它是由几个小查询组成的，其中最左边的那个
-- 查询的 `select_type` 值就是 `primary`

-- 对于包含 `union` 或者 `union all` 的大查询来说，它是由几个小查询组成的，其中除了最左边的那个小查询
-- 以外，其余的小查询的 `select_type` 值就是 `union`
 
-- `Mysql` 选择使用临时表来完成 `union` 查询的去重工作，针对该临时表的查询的 `select_type` 就是 `union result`
explain select * from s1 union select * from s2;
explain select * from s1 union all select * from s2;
 
-- 子查询：
-- 如果包含子查询的查询语句不能够转为对应的 `semi-join` 的形式，并且该子查询是不相关子查询。
-- 该子查询的第一个 `select` 关键字代表的那个查询的 `select_type` 就是 `subquery`
explain select * from s1 where key1 in (select key1 from s2) or key3 = 'a';
 
 
-- 如果包含子查询的查询语句不能够转为对应的 `semi-join` 的形式，并且该子查询是相关子查询，
-- 则该子查询的第一个 `select` 关键字代表的那个查询的 `select_type` 就是 `dependent subquery`
explain select * from s1 
 where key1 in (select key1 from s2 where s1.key2 = s2.key2) or key3 = 'a';
-- 注意的是，select_type 为 `dependent subquery` 的查询可能会被执行多次。
 
 
-- 在包含 `union` 或者 `union all` 的大查询中，如果各个小查询都依赖于外层查询的话，那除了
-- 最左边的那个小查询之外，其余的小查询的 `select_type` 的值就是 `dependent union`。
explain select * from s1 where key1 in (select key1 from s2 where key1 = 'a' union select key1 from s1 where key1 = 'b');

-- 对于包含`派生表`的查询，该派生表对应的子查询的 `select_type` 就是 `derived`
explain select *  from (select key1, count(*) as c from s1 group by key1) as derived_s1 where c > 1;

-- 当查询优化器在执行包含子查询的语句时，选择将子查询物化之后与外层查询进行连接查询时，
-- 该子查询对应的 `select_type` 属性就是 `materialized`
explain select * from s1 where key1 in (select key1 from s2);        -- 子查询被转为了物化表


--  4. partition(略)：匹配的分区信息


--  5. type：针对单表的访问方法
-- 当表中`只有一条记录`并且该表使用的存储引擎的统计数据是精确的，比如 myisam、memory，那么对该表的访问方法就是 `system`
create table t(i int) engine=myisam; 
insert into t values(1);
explain select * from t;

create table tt(i int) engine=innodb;                                -- 换成 innodb
insert into tt values(1);
explain select * from tt;

-- 当我们根据主键或者唯一二级索引列与常数进行等值匹配时，对单表的访问方法就是 `const`
explain select * from s1 where id = 10005;
explain select * from s1 where key2 = 10066;

-- 在连接查询时，如果被驱动表是通过主键或者唯一二级索引列等值匹配的方式进行访问的（如果该主键或者唯一二级索
--     引是联合索引的话，所有的索引列都必须进行等值比较），则对该被驱动表的访问方法就是 `eq_ref`
explain select * from s1 inner join s2 on s1.id = s2.id;

-- 当通过普通的二级索引列与常量进行等值匹配时来查询某个表，那么对该表的访问方法就可能是 `ref`
explain select * from s1 where key1 = 'a';

-- 当对普通二级索引进行等值匹配查询，该索引列的值也可以是 `null` 值时，那么对该表的访问方法就可能是 `ref_or_null`
explain select * from s1 where key1 = 'a' or key1 is null;

-- 单表访问方法时在某些场景下可以使用 `intersection`、`union`、`sort-union` 这三种索引合并的方式来执行查询
explain select * from s1 where key1 = 'a' or key3 = 'a';

-- `unique_subquery` 是针对在一些包含`in`子查询的查询语句中，如果查询优化器决定将 `in` 子查询转换为 `exists` 子查询，
--     而且子查询可以使用到主键进行等值匹配的话，那么该子查询执行计划的 `type` 列的值就是 `unique_subquery`
explain select * from s1 where key2 in (select id from s2 where s1.key1 = s2.key1) or key3 = 'a';

-- 如果使用索引获取某些`范围区间`的记录，那么就可能使用到 `range` 访问方法
explain select * from s1 where key1 in ('a', 'b', 'c');
explain select * from s1 where key1 > 'a' and key1 < 'b';            -- 同上

-- 当我们可以使用索引覆盖，但需要扫描全部的索引记录时，该表的访问方法就是 `index`
explain select key_part2 from s1 where key_part3 = 'a';
explain select * from s1;                                            -- 最熟悉的全表扫描


-- 6. possible_keys 和 key：可能用到的索引 和  实际上使用的索引
explain select * from s1 where key1 > 'z' and key3 = 'a';


-- 7.  key_len：实际使用到的索引长度(即：字节数)
--  帮你检查`是否充分的利用上了索引`，`值越大越好`,主要针对于联合索引，有一定的参考意义。
explain select * from s1 where id = 10005;
explain select * from s1 where key2 = 10126;
explain select * from s1 where key1 = 'a';
explain select * from s1 where key_part1 = 'a';
explain select * from s1 where key_part1 = 'a' and key_part2 = 'b';
explain select * from s1 where key_part1 = 'a' and key_part2 = 'b' and key_part3 = 'c';
explain select * from s1 where key_part3 = 'a';
 
-- 练习：
-- varchar(10)变长字段且允许null  = 10 * ( character set：utf8=3,gbk=2,latin1=1)+1(null)+2(变长字段)
-- varchar(10)变长字段且不允许null = 10 * ( character set：utf8=3,gbk=2,latin1=1)+2(变长字段)
-- char(10)固定字段且允许null    = 10 * ( character set：utf8=3,gbk=2,latin1=1)+1(null)
-- char(10)固定字段且不允许null  = 10 * ( character set：utf8=3,gbk=2,latin1=1)


--  8. ref：当使用索引列等值查询时，与索引列进行等值匹配的对象信息，比如只是一个常数或者是某个列。
explain select * from s1 where key1 = 'a';
explain select * from s1 inner join s2 on s1.id = s2.id;
explain select * from s1 inner join s2 on s2.key1 = upper(s1.key1);


--  9. rows：预估的需要读取的记录条数 值越小越好
explain select * from s1 where key1 > 'z';


--  10. filtered: 某个表经过搜索条件过滤后剩余记录条数的百分比：如果使用的是索引执行的单表扫描，
--      那么计算时需要估计出满足除使用到对应索引的搜索条件外的其他搜索条件的记录有多少条。
explain select * from s1 where key1 > 'z' and common_field = 'a';
 
-- 对于单表查询来说，这个 filtered 列的值没什么意义，我们`更关注在连接查询
-- 中驱动表对应的执行计划记录的 filtered 值`，它决定了被驱动表要执行的次数(即：rows * filtered)
explain select * from s1 inner join s2 on s1.key1 = s2.key1 where s1.common_field = 'a';


-- 11. extra:一些额外的信息
-- 更准确的理解 mysql 到底将如何执行给定的查询语句
explain select 1;                                                    -- 当查询语句的没有 `from` 子句时将会提示该额外信息
explain select * from s1 where 1 != 1;                               -- 查询语句的 `where` 子句永远为 `false` 时将会提示该额外信息

-- 当我们使用全表扫描来执行对某个表的查询，并且该语句的 `where` 子句中有针对该表的搜索条件时，在 `extra` 列中会提示上述额外信息
explain select * from s1 where common_field = 'a';

-- 当使用索引访问来执行表查询，并且该语句的 `where` 子句中除了该索引列之外的其他条件时，`extra` 列中也会提示额外信息
explain select * from s1 where key1 = 'a' and common_field = 'a';

-- 当查询列表处有`min`或者`max`聚合函数，但是并没有符合 `where` 子句中的搜索条件的记录时，将会提示该额外信息
explain select min(key1) from s1 where key1 = 'abcdefg';
explain select min(key1) from s1 where key1 = 'nlpros';              -- nlpros 是 s1表中key1字段真实存在的数据
-- select * from s1 limit 10;

-- 当我们的查询列表以及搜索条件中只包含属于某个索引的列，也就是在可以使用覆盖索引的情况下，
--     在 `extra` 列将会提示该额外信息。比方说下边这个查询中只需要用到 `idx_key1` 而不需要回表操作：
explain select key1,id from s1 where key1 = 'a';

-- 有些搜索条件中虽然出现了索引列，但却不能使用到索引看课件理解索引条件下推
explain select * from s1 where key1 > 'z' and key1 like '%a';
 
-- 在连接查询执行过程中，当被驱动表不能有效的利用索引加快访问速度，Mysql 一般会为其分配一块名叫 `join buffer`
--     的内存块来加快查询速度，也就是我们所讲的`基于块的嵌套循环算法`
explain select * from s1 inner join s2 on s1.common_field = s2.common_field;

-- 当我们使用左（外）连接时，如果 `where` 子句中包含要求被驱动表的某个列等于 `null` 值的搜索条件，
--     而且那个列又是不允许存储 `null` 值的，那么在该表的执行计划的extra列就会提示 `not exists` 额外信息
explain select * from s1 left join s2 on s1.key1 = s2.key1 where s2.id is null;
 
-- 如果执行计划的 `extra` 列出现了 `using intersect(...)` 提示，说明准备使用 `intersect` 索引合并的方式执行查询，
--     括号中的 `...` 表示需要进行索引合并的索引名称；如果出现了 `using union(...)` 提示，说明准备使用 `union`
--     索引合并的方式执行查询；出现了 `using sort_union(...)` 提示，说明准备使用 `sort-union` 索引合并的方式执行查询
explain select * from s1 where key1 = 'a' or key3 = 'a';

-- 当我们的 `limit` 子句的参数为 `0` 时，表示压根儿不打算从表中读出任何记录，将会提示该额外信息
explain select * from s1 limit 0;

-- 有一些情况下对结果集中的记录进行排序是可以使用到索引的
explain select * from s1 order by key1 limit 10;
 
-- 很多情况下排序操作无法使用到索引，只能在内存中（记录较少的时候）或者磁盘中（记录较多的时候）
-- 进行排序，mysql把这种在内存中或者磁盘上进行排序的方式统称为文件排序（英文名：`filesort`）。
-- 如果某个查询需要使用文件排序的方式执行查询，就会在执行计划的 `extra` 列中显示 `using filesort` 提示
explain select * from s1 order by common_field limit 10;
 
-- 在许多查询的执行过程中，Mysql 可能会借助临时表来完成一些功能，比如去重、排序之类的，比如我们
-- 在执行许多包含 `distinct`、`group by`、`union` 等子句的查询过程中，如果不能有效利用索引来完成
-- 查询，Mysql 很有可能寻求通过建立内部的临时表来执行查询。如果查询中使用到了内部的临时表，在执行
-- 计划的 `extra` 列将会显示 `using temporary` 提示
explain select distinct common_field from s1;
-- explain select distinct key1 from s1;
explain select common_field, count(*) as amount from s1 group by common_field; -- 同上。
 
-- 执行计划中出现 `using temporary` 并不是一个好的征兆，因为建立与维护临时表要付出很大成本的，所以
-- 我们`最好能使用索引来替代掉使用临时表`；比如：扫描指定的索引 idx_key1 即可
explain select key1, count(*) as amount from s1 group by key1;
explain format=json select * from s1 inner join s2 on s1.key1 = s2.key2 where s1.common_field = 'a';   -- json格式的 explain
