-- ---------------------------------------------------------------------------------------------------------------------
-- job_info
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_group`;
create table if not exists `job_group`
(
    `id`           int(11) primary key auto_increment,
    `app_name`     varchar(64)  not null           comment '执行器AppName',
    `title`        varchar(32)  not null           comment '执行器名称',
    `order`        int(11)      not null default 0 comment '排序',
    `address_type` tinyint(4)   not null default 0 comment '执行器地址类型：0=自动注册、1=手动录入',
    `address_list` varchar(512)                    comment '执行器地址列表，多地址逗号分隔'
) engine = InnoDB auto_increment = 1 row_format = dynamic;

insert into `job_group` values (1, 'datax-executor', 'datax执行器', 1, 0, null);


-- ---------------------------------------------------------------------------------------------------------------------
-- job_info
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_info`;
create table if not exists `job_info`
(
    `id`                        int(11)      primary key auto_increment,
    `job_group`                 int(11)      not null                    comment '执行器主键ID',
    `job_cron`                  varchar(128) not null                    comment '任务执行CRON',
    `job_desc`                  varchar(255) not null,
    `add_time`                  datetime(0),
    `update_time`               datetime(0),
    `author`                    varchar(64)                              comment '作者',
    `alarm_email`               varchar(255)                             comment '报警邮件',
    `executor_route_strategy`   varchar(50)                              comment '执行器路由策略',
    `executor_handler`          varchar(255)                             comment '执行器任务handler',
    `executor_param`            varchar(512)                             comment '执行器任务参数',
    `executor_block_strategy`   varchar(50)                              comment '阻塞处理策略',
    `executor_timeout`          int(11)      not null default 0          comment '任务执行超时时间，单位秒',
    `executor_fail_retry_count` int(11)      not null default 0          comment '失败重试次数',
    `glue_type`                 varchar(50)  not null                    comment 'GLUE类型',
    `glue_source`               mediumtext                               comment 'GLUE源代码',
    `glue_remark`               varchar(128)                             comment 'GLUE备注',
    `glue_updatetime`           datetime(0)                              comment 'GLUE更新时间',
    `child_jobid`               varchar(255)                             comment '子任务ID，多个逗号分隔',
    `trigger_status`            tinyint(4)   not null default 0          comment '调度状态：0-停止，1-运行',
    `trigger_last_time`         bigint(13)   not null default 0          comment '上次调度时间',
    `trigger_next_time`         bigint(13)   not null default 0          comment '下次调度时间',
    `job_json`                  text                                     comment 'datax运行脚本'
) engine = InnoDB auto_increment = 1 row_format = dynamic;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_jdbc_datasource
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_jdbc_datasource`;
create table if not exists `job_jdbc_datasource`
(
    `id`                bigint(20)   primary key auto_increment            comment '自增主键',
    `datasource_name`   varchar(200) not null                              comment '数据源名称',
    `datasource_group`  varchar(200)          default 'Default'            comment '数据源分组',
    `jdbc_username`     varchar(100) not null                              comment '用户名',
    `jdbc_password`     varchar(200) not null                              comment '密码',
    `jdbc_url`          varchar(500) not null                              comment 'jdbc url',
    `jdbc_driver_class` varchar(200)                                       comment 'jdbc驱动类',
    `status`            tinyint(1)   not null default 1                    comment '状态：0删除 1启用 2禁用',
    `create_by`         varchar(20)                                        comment '创建人',
    `create_date`       datetime(0)           default current_timestamp(0) comment '创建时间',
    `update_by`         varchar(20)                                        comment '更新人',
    `update_date`       datetime(0)                                        comment '更新时间',
    `comments`          varchar(1000)                                      comment '备注'
) engine = InnoDB auto_increment = 1 comment = 'jdbc数据源配置' row_format = dynamic;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_lock
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_lock`;
create table if not exists `job_lock`
(
    `lock_name` varchar(50) primary key comment '锁名称'
) engine = InnoDB row_format = dynamic;

insert into `job_lock` values ('schedule_lock');


-- ---------------------------------------------------------------------------------------------------------------------
-- job_log
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_log`;
create table if not exists `job_log`
(
    `id`                        bigint(20)   primary key auto_increment,
    `job_group`                 int(11)      not null                    comment '执行器主键 ID',
    `job_id`                    int(11)      not null                    comment '任务主键 ID',
    `job_desc`                  varchar(255)                             comment '任务描述',
    `executor_address`          varchar(255)                             comment '执行器地址，本次执行的地址',
    `executor_handler`          varchar(255)                             comment '执行器任务handler',
    `executor_param`            varchar(512)                             comment '执行器任务参数',
    `executor_sharding_param`   varchar(20)                              comment '执行器任务分片参数，格式如 1/2',
    `executor_fail_retry_count` int(11)               default 0          comment '失败重试次数',
    `trigger_time`              datetime(0)                              comment '调度-时间',
    `trigger_code`              int(11)      not null                    comment '调度-结果',
    `trigger_msg`               text                                     comment '调度-日志',
    `handle_time`               datetime(0)                              comment '执行-时间',
    `handle_code`               int(11)      not null                    comment '执行-状态',
    `handle_msg`                text                                     comment '执行-日志',
    `alarm_status`              tinyint(4)   not null default 0          comment '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败',
    `process_id`                varchar(20)                              comment 'datax 进程 ID',
    `max_id`                    bigint(20)                               comment '增量表 MAX ID',
    index `inx_jl_tt` (`trigger_time`) using btree,
    index `inx_jl_hc` (`handle_code`) using btree
) engine = InnoDB auto_increment = 0 row_format = dynamic;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_log_report
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_log_report`;
create table if not exists `job_log_report`
(
    `id`            int(11)     primary key auto_increment,
    `trigger_day`   datetime(0)                             comment '调度-时间',
    `running_count` int(11)     not null default 0          comment '运行中-日志数量',
    `suc_count`     int(11)     not null default 0          comment '执行成功-日志数量',
    `fail_count`    int(11)     not null default 0          comment '执行失败-日志数量',
    unique index `ui_jlp_td` (`trigger_day`) using btree
) engine = InnoDB auto_increment = 28 row_format = dynamic;

insert into `job_log_report` values (20, '2022-12-09 00:00:00', 0, 0, 0);
insert into `job_log_report` values (21, '2022-12-10 00:00:00', 77, 52, 23);
insert into `job_log_report` values (22, '2022-12-11 00:00:00', 9, 2, 11);
insert into `job_log_report` values (23, '2022-12-13 00:00:00', 9, 48, 74);
insert into `job_log_report` values (24, '2022-12-12 00:00:00', 10, 8, 30);
insert into `job_log_report` values (25, '2022-12-14 00:00:00', 78, 45, 66);
insert into `job_log_report` values (26, '2022-12-15 00:00:00', 24, 76, 9);
insert into `job_log_report` values (27, '2022-12-16 00:00:00', 23, 85, 10);


-- ---------------------------------------------------------------------------------------------------------------------
-- job_logglue
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_logglue`;
create table if not exists `job_logglue`
(
    `id`          int(11)      primary key auto_increment,
    `job_id`      int(11)      not null                    comment '任务，主键ID',
    `glue_type`   varchar(50)                              comment 'GLUE 类型',
    `glue_source` mediumtext                               comment 'GLUE 源代码',
    `glue_remark` varchar(128) not null                    comment 'GLUE 备注',
    `add_time`    datetime(0),
    `update_time` datetime(0)
) engine = InnoDB auto_increment = 1 row_format = dynamic;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_registry
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_registry`;
create table if not exists `job_registry`
(
    `id`             int(11)      primary key auto_increment,
    `registry_group` varchar(50)  not null,
    `registry_key`   varchar(191) not null,
    `registry_value` varchar(191) not null,
    `update_time`    datetime(0),
    index `inx_jr_rg_rk_rv` (`registry_group`, `registry_key`, `registry_value`) using btree
) engine = InnoDB auto_increment = 26 row_format = dynamic;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_user
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_user`;
create table if not exists `job_user`
(
    `id`         int(11)      primary key auto_increment,
    `username`   varchar(50)  not null                    comment '账号',
    `password`   varchar(100) not null                    comment '密码',
    `role`       varchar(50)  null                        comment '角色：0-普通用户、1-管理员',
    `permission` varchar(255) null                        comment '权限：执行器ID列表，多个逗号分割',
    unique index `ui_ju_un` (`username`) using btree
) engine = InnoDB auto_increment = 10 row_format = dynamic;

insert into `job_user` values (1, 'admin', '$2a$10$2KCqRbra0Yn2TwvkZxtfLuWuUP5KyCWsljO/ci5pLD27pqR3TV1vy', 'ROLE_ADMIN', null);


-- ---------------------------------------------------------------------------------------------------------------------
-- v2.1.1脚本更新
-- ---------------------------------------------------------------------------------------------------------------------
alter table `job_info` add column `replace_param` varchar(100) null             comment '动态参数'  after `job_json`;
alter table `job_info` add column `jvm_param`     varchar(200) null             comment 'jvm参数'   after `replace_param`;
alter table `job_info` add column `time_offset`   int(11)      null default '0' comment '时间偏移量' after `jvm_param`;

-- 增量改版脚本更新
alter table `job_info` drop column `time_offset`;
alter table `job_info` add  column `inc_start_time` datetime comment '增量初始时间' after `jvm_param`;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_template
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_template`;
create table if not exists `job_template`
(
    `id`                        int(11)      primary key auto_increment,
    `job_group`                 int(11)      not null                    comment '执行器主键ID',
    `job_cron`                  varchar(128) not null                    comment '任务执行CRON',
    `job_desc`                  varchar(255) not null,
    `add_time`                  datetime(0),
    `update_time`               datetime(0),
    `user_id`                   int(11)      not null                    comment '修改用户',
    `alarm_email`               varchar(255)                             comment '报警邮件',
    `executor_route_strategy`   varchar(50)                              comment '执行器路由策略',
    `executor_handler`          varchar(255)                             comment '执行器任务handler',
    `executor_param`            varchar(512)                             comment '执行器参数',
    `executor_block_strategy`   varchar(50)                              comment '阻塞处理策略',
    `executor_timeout`          int(11)      not null default 0          comment '任务执行超时时间，单位秒',
    `executor_fail_retry_count` int(11)      not null default 0          comment '失败重试次数',
    `glue_type`                 varchar(50)  not null                    comment 'GLUE 类型',
    `glue_source`               mediumtext                               comment 'GLUE 源代码',
    `glue_remark`               varchar(128)                             comment 'GLUE 备注',
    `glue_updatetime`           datetime(0)                              comment 'GLUE 更新时间',
    `child_jobid`               varchar(255)                             comment '子任务ID，多个逗号分隔',
    `trigger_last_time`         bigint(13)   not null default 0          comment '上次调度时间',
    `trigger_next_time`         bigint(13)   not null default 0          comment '下次调度时间',
    `job_json`                  text                                     comment 'datax 运行脚本',
    `jvm_param`                 varchar(200)                             comment 'jvm 参数',
    `project_id`                int(11)                                  comment '所属项目 ID'
) engine = InnoDB auto_increment = 1 row_format = dynamic;

-- 添加数据源字段
alter table `job_jdbc_datasource` add column `datasource` varchar(45) not null comment '数据源' after `datasource_name`;

-- 添加分区字段
alter table `job_info` add column `partition_info` varchar(100) comment '分区信息' after `inc_start_time`;


-- ---------------------------------------------------------------------------------------------------------------------
-- 2.1.1版本新增
-- ---------------------------------------------------------------------------------------------------------------------
-- 最近一次执行状态
alter table `job_info` add column `last_handle_code` int(11) not null default '0' comment '最近一次执行状态' after `partition_info`;

-- zookeeper地址
alter table `job_jdbc_datasource` add    column `zk_adress`                          varchar(200)                 after `jdbc_driver_class`;
alter table `job_info`            change column `executor_timeout` `executor_timeout` int(11) not null default '0' comment '任务执行超时时间，单位分钟';

-- 用户名密码改为非必填
alter table `job_jdbc_datasource` change column `jdbc_username` `jdbc_username` varchar(100) comment '用户名';
alter table `job_jdbc_datasource` change column `jdbc_password` `jdbc_password` varchar(200) comment '密码';

-- 添加 mongodb 数据库名字段
alter table `job_jdbc_datasource` add column `database_name` varchar(45) comment '数据库名' after `datasource_group`;

-- 添加执行器资源字段
alter table `job_registry` add column `cpu_usage`    double after `registry_value`;
alter table `job_registry` add column `memory_usage` double after `cpu_usage`;
alter table `job_registry` add column `load_average` double after `memory_usage`;


-- ---------------------------------------------------------------------------------------------------------------------
-- job_permission
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists `job_permission`;
create table if not exists `job_permission`
(
    `id`          int(11)      primary key auto_increment comment '主键',
    `name`        varchar(50)  not null                   comment '权限名',
    `description` varchar(11)                             comment '权限描述',
    `url`         varchar(255),
    `pid`         int(11)
) engine = InnoDB auto_increment = 3 row_format = dynamic;

alter table `job_info` add column `replace_param_type` varchar(255) comment '增量时间格式'  after `last_handle_code`;
alter table `job_info` add column `project_id`         int(11)      comment '所属项目 id'   after `job_desc`;
alter table `job_info` add column `reader_table`       varchar(255) comment 'reader 表名称' after `replace_param_type`;
alter table `job_info` add column `primary_key`        varchar(50)  comment '增量表主键'    after `reader_table`;
alter table `job_info` add column `inc_start_id`       varchar(20)  comment '增量初始 ID'   after `primary_key`;
alter table `job_info` add column `increment_type`     tinyint(4)   comment '增量类型'      after `inc_start_id`;
alter table `job_info` add column `datasource_id`      bigint(11)   comment '数据源 ID'     after `increment_type`;

create table if not exists `job_project`
(
    `id`          int(11)      primary key auto_increment   comment 'key',
    `name`        varchar(100)                              comment 'project name',
    `description` varchar(200),
    `user_id`     int(11)                                   comment 'creator id',
    `flag`        tinyint(4)   default 1                    comment '0 not available, 1 available',
    `create_time` datetime(0)  default current_timestamp(0) comment 'create time',
    `update_time` datetime(0)  default current_timestamp(0) comment 'update time'
) engine = InnoDB auto_increment = 1 row_format = dynamic;

alter table `job_info` change column `author`         `user_id`        int(11)    not null  comment '修改用户';
alter table `job_info` change column `increment_type` `increment_type` tinyint(4) default 0 comment '增量类型';
