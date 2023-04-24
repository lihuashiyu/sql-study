# noinspection NonAsciiCharactersForFile
-- ---------------------------------------------------------------------------------------------------------------------
-- 创建学生表
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists student_info;
create table if not exists student_info
(
    stu_id   varchar(32) comment '学生 ID',
    stu_name varchar(32) comment '学生姓名',
    birthday varchar(32) comment '出生日期',
    sex      varchar(32) comment '性别'
);

insert into student_info (stu_id, stu_name, birthday, sex)
values ('001', '彭于晏', '1995-05-16', '男'),
       ('002', '胡歌',   '1994-03-20', '男'),
       ('003', '周杰伦', '1995-04-30', '男'),
       ('004', '刘德华', '1998-08-28', '男'),
       ('005', '唐国强', '1993-09-10', '男'),
       ('006', '陈道明', '1992-11-12', '男'),
       ('007', '陈坤',   '1999-04-09', '男'),
       ('008', '吴京',   '1994-02-06', '男'),
       ('009', '郭德纲', '1992-12-05', '男'),
       ('010', '于谦',   '1998-08-23', '男'),
       ('011', '潘长江', '1995-05-27', '男'),
       ('012', '杨紫',   '1996-12-21', '女'),
       ('013', '蒋欣',   '1997-11-08', '女'),
       ('014', '赵丽颖', '1990-01-09', '女'),
       ('015', '刘亦菲', '1993-01-14', '女'),
       ('016', '周冬雨', '1990-06-18', '女'),
       ('017', '范冰冰', '1992-07-04', '女'),
       ('018', '李冰冰', '1993-09-24', '女'),
       ('019', '邓紫棋', '1994-08-31', '女'),
       ('020', '宋丹丹', '1991-03-01', '女');

-- ---------------------------------------------------------------------------------------------------------------------
-- 创建课程表
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists course_info;
create table if not exists course_info
(
    course_id   varchar(32) COMMENT '课程 ID',
    course_name varchar(32) COMMENT '课程名',
    tea_id      varchar(32) COMMENT '任课老师 ID'
);

insert into course_info (course_id, course_name, tea_id)
values ('01', '语文', '1003'),
       ('02', '数学', '1001'),
       ('03', '英语', '1004'),
       ('04', '体育', '1002'),
       ('05', '音乐', '1002');

-- ---------------------------------------------------------------------------------------------------------------------
-- 创建老师表
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists teacher_info;
create table if not exists teacher_info
(
    tea_id   varchar(32) COMMENT '老师 ID',
    tea_name varchar(32) COMMENT '老师姓名'
);

insert into teacher_info (tea_id, tea_name)
values ('1001', '张高数'),
       ('1002', '李体音'),
       ('1003', '王子文'),
       ('1004', '刘丽英');

-- ---------------------------------------------------------------------------------------------------------------------
-- 创建分数表
-- ---------------------------------------------------------------------------------------------------------------------
drop table if exists score_info;
create table if not exists score_info
(
    stu_id    varchar(32) COMMENT '学生 ID',
    course_id varchar(32) COMMENT '课程 ID',
    score     int COMMENT '成绩'
);

insert into score_info (stu_id, course_id, score)
values ('001', '01', '94'),
       ('002', '01', '74'),
       ('004', '01', '85'),
       ('005', '01', '64'),
       ('006', '01', '71'),
       ('007', '01', '48'),
       ('008', '01', '56'),
       ('009', '01', '75'),
       ('010', '01', '84'),
       ('011', '01', '61'),
       ('012', '01', '44'),
       ('013', '01', '47'),
       ('014', '01', '81'),
       ('015', '01', '90'),
       ('016', '01', '71'),
       ('017', '01', '58'),
       ('018', '01', '38'),
       ('019', '01', '46'),
       ('020', '01', '89'),
       ('001', '02', '63'),
       ('002', '02', '84'),
       ('004', '02', '93'),
       ('005', '02', '44'),
       ('006', '02', '90'),
       ('007', '02', '55'),
       ('008', '02', '34'),
       ('009', '02', '78'),
       ('010', '02', '68'),
       ('011', '02', '49'),
       ('012', '02', '74'),
       ('013', '02', '35'),
       ('014', '02', '39'),
       ('015', '02', '48'),
       ('016', '02', '89'),
       ('017', '02', '34'),
       ('018', '02', '58'),
       ('019', '02', '39'),
       ('020', '02', '59'),
       ('001', '03', '79'),
       ('002', '03', '87'),
       ('004', '03', '89'),
       ('005', '03', '99'),
       ('006', '03', '59'),
       ('007', '03', '70'),
       ('008', '03', '39'),
       ('009', '03', '60'),
       ('010', '03', '47'),
       ('011', '03', '70'),
       ('012', '03', '62'),
       ('013', '03', '93'),
       ('014', '03', '32'),
       ('015', '03', '84'),
       ('016', '03', '71'),
       ('017', '03', '55'),
       ('018', '03', '49'),
       ('019', '03', '93'),
       ('020', '03', '81'),
       ('001', '04', '54'),
       ('002', '04', '100'),
       ('004', '04', '59'),
       ('005', '04', '85'),
       ('007', '04', '63'),
       ('009', '04', '79'),
       ('010', '04', '34'),
       ('013', '04', '69'),
       ('014', '04', '40'),
       ('016', '04', '94'),
       ('017', '04', '34'),
       ('020', '04', '50'),
       ('005', '05', '85'),
       ('007', '05', '63'),
       ('009', '05', '79'),
       ('015', '05', '59'),
       ('018', '05', '87');

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询学生的总成绩并按照总成绩降序排序
-- ---------------------------------------------------------------------------------------------------------------------
select stu_id,
       sum(score) as s
from score_info
group by stu_id
order by s desc ;

-- ---------------------------------------------------------------------------------------------------------------------
-- 学生id 语文 数学 英语 有效课程数 有效平均成绩
-- ---------------------------------------------------------------------------------------------------------------------
select si.stu_id,
       sum(if(si.course_id = '01', si.score, 0)) as `语文`,
       sum(if(si.course_id = '02', si.score, 0)) as `数学`,
       sum(if(si.course_id = '03', si.score, 0)) as `英语`,
       count(*)                                  as `有效课程数`,
       avg(si.score)                             as `有效平均成绩`
from score_info as si
inner join course_info as ci
    on si.course_id = ci.course_id
group by si.stu_id
order by `有效平均成绩` desc;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询一共参加三门课程且其中一门为语文课程的学生的id和姓名
-- ---------------------------------------------------------------------------------------------------------------------
select si.stu_id,
       s.stu_name,
       count(si.course_id) as c
from score_info si inner join
(
    select stu_id
    from score_info
    where course_id = '01'
) t1 on si.stu_id = t1.stu_id
inner join student_info s
    on si.stu_id = s.stu_id
group by si.stu_id, s.stu_name
having c = 3
order by si.stu_id;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询所有课程成绩均小于 60 分的学生的学号、姓名
-- ---------------------------------------------------------------------------------------------------------------------
select t.stu_id,
       t.stu_name
from
(
    select si.stu_id,
           s.stu_name,
           max(si.score) as max_score
    from score_info si inner join student_info s
        on si.stu_id = s.stu_id
    group by si.stu_id, s.stu_name
) t where t.max_score < '60';

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询没有学全所有课的学生的学号、姓名
-- ---------------------------------------------------------------------------------------------------------------------
select t1.stu_id,
       t1.stu_name
from
(
    select si.stu_id,
           s.stu_name,
           count(si.course_id) as c1
    from score_info si inner join student_info s
        on si.stu_id = s.stu_id
    group by si.stu_id, s.stu_name
) t1 left join
(
    select count(*) as c2
    from course_info
) t2 on t1.c1 < t2.c2;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询出只选修了三门课程的全部学生的学号和姓名
-- ---------------------------------------------------------------------------------------------------------------------
select t.stu_id,
       t.stu_name
from
(
    select si.stu_id,
           s.stu_name,
           count(si.course_id) as c
    from score_info si inner join student_info s
        on si.stu_id = s.stu_id
    group by si.stu_id, s.stu_name
) t where t.c = 3;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询有两门以上的课程不及格的同学的学号及其平均成绩
-- ---------------------------------------------------------------------------------------------------------------------
select si.stu_id,
       avg(si.score) as avgs
from score_info si inner join
(
    select si.stu_id,
           sum(if(si.score < '60', 1, 0)) as tc
    from score_info si
    group by si.stu_id
    having tc > 1
) t on si.stu_id = t.stu_id
group by si.stu_id;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询所有学生的学号、姓名、选课数、总成绩
-- ---------------------------------------------------------------------------------------------------------------------
select st.stu_id,
       st.stu_name,
       count(sc.course_id) as tc,
       sum(sc.score) as sc
from student_info st
inner join score_info sc
    on st.stu_id = sc.stu_id
group by st.stu_id, st.stu_name;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询平均成绩大于 85 的所有学生的学号、姓名和平均成绩
-- ---------------------------------------------------------------------------------------------------------------------
select sc.stu_id,
       st.stu_name,
       avg(sc.score) as avgs
from score_info sc
inner join student_info st
    on sc.stu_id = st.stu_id
group by sc.stu_id, st.stu_name
having avgs > 85;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询学生的选课情况：学号，姓名，课程号，课程名称
-- ---------------------------------------------------------------------------------------------------------------------
select st.stu_id,
       st.stu_name,
       ci.course_id,
       ci.course_name
from student_info st
inner join score_info si
    on st.stu_id = si.stu_id
inner join course_info as ci
    on si.course_id = ci.course_id;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询出每门课程的及格人数和不及格人数
-- ---------------------------------------------------------------------------------------------------------------------
select ci.course_id,
       ci.course_name,
       t.y,
       t.n
from course_info ci
inner join
(
    select si.course_id,
           sum(if(si.score >= 60, 1, 0)) as y,
           sum(if(si.score <  60, 1, 0)) as n
    from score_info si
    group by si.course_id
) t on ci.course_id = t.course_id;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询课程编号为 03 且课程成绩在 80 分以上的学生的学号和姓名及课程信息
-- ---------------------------------------------------------------------------------------------------------------------
select sc.stu_id,
       st.stu_name,
       sc.course_id,
       ci.course_name
from score_info as sc
inner join student_info st
    on sc.stu_id = st.stu_id
inner join course_info ci
    on sc.course_id = ci.course_id
where sc.course_id = '03' and sc.score >= '80';

-- ---------------------------------------------------------------------------------------------------------------------
-- 课程编号为 "01" 且课程分数小于60，按分数降序排列的学生信息
-- ---------------------------------------------------------------------------------------------------------------------
select sc.stu_id,
       st.stu_name,
       st.birthday,
       st.sex,
       sc.course_id
from score_info as sc
inner join student_info st
    on sc.stu_id = st.stu_id
where sc.course_id = '01' and sc.score < '60'
order by sc.score desc;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询所有课程成绩在 70 分以上的学生的姓名、课程名称和分数，按分数升序排列
-- ---------------------------------------------------------------------------------------------------------------------
select st.stu_name,
       ci.course_name,
       sc.score
from score_info sc
inner join
(
    select sc.stu_id
    from score_info as sc
    group by sc.stu_id
    having min(sc.score) >= 70
) t on sc.stu_id = t.stu_id
inner join student_info st
    on sc.stu_id = st.stu_id
inner join course_info ci
    on sc.course_id = ci.course_id
order by sc.score;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询该学生不同课程的成绩相同的学生编号、课程编号、学生成绩
-- ---------------------------------------------------------------------------------------------------------------------
select s1.stu_id,
       s1.course_id,
       s1.score
from score_info as s1
inner join score_info as s2
    on      s1.stu_id    =  s2.stu_id
        and s1.score     =  s2.score
        and s1.course_id != s2.course_id
order by stu_id, course_id;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询课程编号为 01 的课程比 02 的课程成绩高的所有学生的学号
-- ---------------------------------------------------------------------------------------------------------------------
select t1.stu_id
from
(
    select stu_id,
           score
    from score_info
    where course_id = '01'
) t1 inner join
(
    select stu_id,
           score
    from score_info
    where course_id = '02'
) t2 on t1.stu_id = t2.stu_id
    and t1.score > t2.score;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询学过编号为 01 的课程并且也学过编号为 02 的课程的学生的学号、姓名
-- ---------------------------------------------------------------------------------------------------------------------
select t1.stu_id,
       st.stu_name
from
(
    select stu_id,
           score
    from score_info
    where course_id = '01'
) t1 inner join
(
    select stu_id,
           score
    from score_info
    where course_id = '02'
) t2 on t1.stu_id = t2.stu_id
inner join student_info st
    on t2.stu_id = st.stu_id;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询学过 李体音 老师所教的所有课的同学的学号、姓名
-- ---------------------------------------------------------------------------------------------------------------------
with tmp as
(
    select ci.course_id
    from course_info  as ci
    inner join teacher_info as ti
        on ci.tea_id = ti.tea_id
    where ti.tea_name = '李体音'
)
select s.stu_id,
       s.stu_name
from tmp inner join score_info si
    on tmp.course_id = si.course_id
inner join student_info s
    on si.stu_id = s.stu_id
inner join
(
    select count(*) as course_count
    from tmp
) t
group by s.stu_id, s.stu_name, t.course_count
having count(*) = t.course_count;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询学过 "李体音" 老师所讲授的任意一门课程的学生的学号、姓名
-- ---------------------------------------------------------------------------------------------------------------------
select st.stu_id,
       st.stu_name
from
student_info            as st
inner join score_info   as sc
    on st.stu_id = sc.stu_id
inner join course_info  as ci
    on sc.course_id = ci.course_id
inner join teacher_info as ti
    on ci.tea_id = ti.tea_id
where ti.tea_name = '李体音'
group by st.stu_id, st.stu_name;

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询没学过 "李体音" 老师讲授的任一门课程的学生姓名
-- ---------------------------------------------------------------------------------------------------------------------
select s.stu_name
from student_info s
where s.stu_id not in
(
    select si.stu_id
    from teacher_info                   as ti
    inner join course_info              as ci
        on ci.tea_id = ti.tea_id
    inner join score_info si
        on ci.course_id = si.course_id
    where ti.tea_name = '李体音'
    group by ci.course_id
);

-- ---------------------------------------------------------------------------------------------------------------------
-- 查询至少有一门课与学号为 001 的学生所学课程相同的学生的学号和姓名
-- ---------------------------------------------------------------------------------------------------------------------
select s.stu_id,
       s.stu_name
from student_info               as s
inner join score_info           as si
    on s.stu_id = si.stu_id
inner join
(
    select si.course_id
    from score_info             as si
    inner join student_info     as s
        on si.stu_id = s.stu_id
    where si.stu_id = '001'
) t on si.course_id = t.course_id
group by s.stu_id, s.stu_name;

-- ---------------------------------------------------------------------------------------------------------------------
-- 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
-- ---------------------------------------------------------------------------------------------------------------------
select st.stu_id,
       st.stu_name,
       ci.course_name,
       t.avg_score
from student_info st
inner join
(
    select stu_id,
           avg(score) as avg_score
    from score_info
    group by stu_id
) t on st.stu_id = t.stu_id
inner join score_info si
    on t.stu_id = si.stu_id
inner join course_info ci
    on si.course_id = ci.course_id
order by t.avg_score desc;
