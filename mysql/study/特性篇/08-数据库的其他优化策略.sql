-- 08-数据库的其他优化策略
create table user1
(
    id   int          not null      auto_increment,
    name varchar(255) default null,
    age  int          default null,
    sex  varchar(255) default null,
    primary key (id),
    key idx_name (name) using btree
) engine = INNODB auto_increment = 1;

set global log_bin_trust_function_creators = 1;

delimiter //
    create function rand_num(from_num int, to_num int) returns int(11)
    begin
        declare i int default 0;
        set i = floor(from_num + rand() * (to_num - from_num + 1));
        return i;
    end
// delimiter ;

delimiter //
    create procedure insert_user(max_num int)
    begin
        declare i int default 0;
        set autocommit = 0;
        repeat
            set i = i + 1;
            insert into user1 (NAME, age, sex)
            values ("atguigu", rand_num(1, 20), "male");
        until i = max_num end repeat;
        commit;
    end
// delimiter ;

-- -- 
call insert_user(1000);
show index from user1;
select * from user1;
update user1 set name = 'atguigu03' where id = 3;

analyze table user1;                                               -- 分析表
check table user1;                                                 -- 检查表
create table t1 (id int, name varchar(15)) engine = MYISAM;      -- 优化表
optimize table t1;

create table t2 (id int, name varchar(15)) engine = INNODB;
optimize table t2;

create tablespace atguigu1 add datafile 'atguigu1.ibd' file_block_size = 16k;
create table test (id int, NAME varchar(10)) engine = INNODB default charset utf8mb4 tablespace atguigu1;
alter table test tablespace atguigu1;
drop tablespace atguigu1;
drop table test;
