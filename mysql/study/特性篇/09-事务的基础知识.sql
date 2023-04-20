-- 09- 事务的基础知识

-- 1.事务的完成过程：① 开启事务；② 一系列的 dml 操作；③ 事务结束状态：提交状态(commit) 、中止状态(rollback)


-- 2. 显式事务
--     2.1 如何开启？ 使用关键字：start transaction  或 begin
--          start transaction 后面可以跟：read only / read write (默认) / with consistent snapshot
--     2.2 保存点(savepoint)


-- 3. 隐式事务
--      3.1 关键字：autocommit： set autocommit = false;
show variables like 'autocommit';                                    -- 默认是 ON
update `account` set `balance` = `balance` - 10 where `id` = 1;          -- 此时这条 dml 操作是一个独立的事务
update `account` set `balance` = `balance` + 10 where `id` = 2;          -- 此时这条 dml 操作是一个独立的事务

-- 3.2 如果关闭自动提交？
set autocommit = false;                                              -- 方式1：针对 DML 操作有效，对 DDL 无效
update `account` set `balance` = `balance` - 10 where `id` = 1;
update `account` set `balance` = `balance` + 10 where `id` = 2;
commit;                                                              -- 或 rollback;

-- 方式 2：我们在 autocommit 为 true 的情况下，使用 start transaction 或 begin 开启事务，DML 操作不会自动提交
start transaction;
update `account` set `balance` = `balance` - 10 where `id` = 1;
update `account` set `balance` = `balance` + 10 where `id` = 2;
commit;                                                              -- 或 rollback;

-- 4. 案例分析：set autocommit = true;  举例1： commit 和 rollback
create table `user3` (`NAME` varchar(15) primary key);                  -- 情况 1
select * from `user3`;
begin;
insert into `user3` values ('张三');                                   -- 此时不会自动提交数据
commit;

begin;                                                               -- 开启一个新的事务
insert into `user3` values ('李四');                                  -- 此时不会自动提交数据
insert into `user3` values ('李四');                                  -- 受主键的影响，不能添加成功
rollback;

select * from `user3`;

truncate table `user3`;                                              -- -- 情况2：DDL 自动提交
select * from `user3`;

begin;
insert into `user3` values ('张三');                                   -- 此时不会自动提交数据
commit;

insert into `user3` values ('李四');                                   --  DML默认(autocommit 为 true)会自动提交
insert into `user3` values ('李四');                                   -- 事务的失败的状态
rollback;

select * from `user3`;

truncate table `user3`;                                                -- 情况3：
select * from `user3`;
select @@`completion_type`;
set @@`completion_type` = 1;

begin;
insert into `user3` values ('张三');
commit;

select * from `user3`;

insert into `user3` values ('李四');
insert into `user3` values ('李四');
rollback;

select * from `user3`;

-- 举例2：体会 INNODB 和 MyISAM
create table `test1` (`i` int) engine = INNODB;
create table `test2` (`i` int) engine = MYISAM;

begin;                                                               -- 针对于 innodb 表
insert into `test1` values (1);
rollback;
select * from `test1`;

begin;                                                               -- 针对于 MyISAM 表：不支持事务
insert into `test2` values (1);
rollback;
select * from `test2`;

-- 举例3：体会 savepoint
create table `user3` (`name` varchar(15), `balance` decimal(10, 2));
begin;
insert into `user3`(`name`, `balance`) values ('张三', 1000);
commit;
select * from `user3`;

begin;
update `user3` set `balance` = `balance` - 100 where `name` = '张三';
update `user3` set `balance` = `balance` - 100 where `name` = '张三';
savepoint `s1`;                                                      -- 设置保存点
update `user3` set `balance` = `balance` + 1 where `name` = '张三';
rollback to `s1`;                                                    -- 回滚到保存点

select * from `user3`;
rollback;                                                            -- 回滚操作
select * from `user3`;
