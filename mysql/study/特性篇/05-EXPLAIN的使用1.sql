explain select * from student_info;
select * from student_info limit 10;
explain delete from student_info where id = 2;
describe delete from student_info where id = 2;

-- 创建表
create table if not exists s1
(
    id           int auto_increment,
    key1         varchar(100),
    key2         int,
    key3         varchar(100),
    key_part1    varchar(100),
    key_part2    varchar(100),
    key_part3    varchar(100),
    common_field varchar(100),
    primary key (id),
    index        idx_key1 (key1),
    unique index idx_key2 (key2),
    index        idx_key3 (key3),
    index        idx_key_part (key_part1, key_part2, key_part3)
) engine = INNODB;

create table if not exists s2
(
    id           int auto_increment,
    key1         varchar(100),
    key2         int,
    key3         varchar(100),
    key_part1    varchar(100),
    key_part2    varchar(100),
    key_part3    varchar(100),
    common_field varchar(100),
    primary key (id),
    index        idx_key1 (key1),
    unique index idx_key2 (key2),
    index        idx_key3 (key3),
    index        idx_key_part (key_part1, key_part2, key_part3)
) engine = INNODB;

-- 创建存储函数：
delimiter //
    create function rand_string1(n int) returns varchar(255) -- 该函数会返回一个字符串
    begin
        declare chars_str varchar(100) default 'abcdefghijklmnopqrstuvwxyzABCDEFJHIJKLMNOPQRSTUVWXYZ';
        declare return_str varchar(255) default '';
        declare i int default 0;
        while i < n
            do
                set return_str = concat(return_str, substring(chars_str, floor(1 + rand() * 52), 1));
                set i = i + 1;
            end while;
        return return_str;
    end
// delimiter ;

-- set global log_bin_trust_function_creators = 1;

-- 创建存储过程：
delimiter //
    create procedure insert_s1(in min_num int(10), in max_num int(10))
    begin
        declare i int default 0;
        set autocommit = 0;
        repeat set i = i + 1;
        insert into s1
        values ((min_num + i),
                rand_string1(6),
                (min_num + 30 * i + 5),
                rand_string1(6),
                rand_string1(10),
                rand_string1(5),
                rand_string1(10),
                rand_string1(10)); until i = max_num end repeat;
        commit;
    end
// delimiter ;

delimiter //
    create procedure insert_s2(in min_num int(10), in max_num int(10))
    begin
        declare i int default 0;
        set autocommit = 0;
        repeat
            set i = i + 1;
            insert into s2
            values ((min_num + i),      rand_string1(6),  (min_num + 30 * i + 5),
                    rand_string1(6),  rand_string1(10),  rand_string1(5),
                    rand_string1(10), rand_string1(10));
        until i = max_num end repeat;
        commit;
    end
// delimiter ;

-- 调用存储过程
call insert_s1(10001, 10000);
call insert_s2(10001, 10000);
select count(*) from s1;
select count(*) from s2;
