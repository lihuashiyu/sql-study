-- 10-事务日志


create table test_load (a int, b char(80)) engine = INNODB;

-- 创建存储过程，用于向 test_load 中添加数据
delimiter //
    create procedure p_load(count int unsigned)
    begin
        declare s int unsigned default 1;
        declare c char(80) default repeat('a', 80);
        while s <= count
        do
            insert into test_load select null, c;
            commit;
            set s = s + 1;
        end while;
    end
// delimiter ;

show variables like 'innodb_flush_log_at_trx_commit';                -- 测试1：设置查看参数
-- set global innodb_flush_log_at_trx_commit = 1;

call p_load(30000);                                           -- 调用存储过程：1 min 28 sec

truncate table test_load;                                           -- 测试2：
select count(*) from test_load;
set global innodb_flush_log_at_trx_commit = 0;
show variables like 'innodb_flush_log_at_trx_commit';
call p_load(30000);                                           -- 调用存储过程：37.945 sec

truncate table test_load;                                           -- 测试3：
select count(*) from test_load;
set global innodb_flush_log_at_trx_commit = 2;
show variables like 'innodb_flush_log_at_trx_commit';
call p_load(30000);                                           -- 调用存储过程：45.173 sec
