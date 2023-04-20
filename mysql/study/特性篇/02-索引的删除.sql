--  02-索引的删除

show index from `book5`;
alter table `book5` drop index `idx_cmt`;                            -- 方式1：alter table .... drop index ....
drop index `uk_idx_bname` on `book5`;                                -- 方式2：drop index ... on ...
alter table `book5` drop column `book_name`;                         -- 测试：删除联合索引中的相关字段，索引的变化
alter table `book5` drop column `book_id`;
alter table `book5` drop column `info`;
