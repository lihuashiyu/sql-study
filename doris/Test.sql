show databases ;

set password for 'root' = password ('111111');

create user 'issac' identified by '111111';

create database if not exists test;
create database if not exists issac;
create database if not exists ubuntu;

grant all on test.* to issac;
grant all on issac.* to issac;
grant all on ubuntu.* to issac;



create table if not exists user_behavior
(
    user_id          int        comment '用户ID：序列化后的用户ID，',
    goods_id         int        comment '商品ID：序列化后的商品ID，',
    item_category_id int        comment '商品类目ID：序列化后的商品所属类目ID，',
    behavior_type_id varchar(8) comment '行为类型：序列化后的用户ID；pv：商品详情页；pv：等价于点击，buy：商品购买，cart：将商品加入购物车，fav：收藏商品',
    timestamp        int        comment '行为发生的时间戳：序列化后的用户ID，',
) engine = InnoDB comment = '淘宝用户行为数据集'
