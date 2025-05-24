-- 项目数库
DROP DATABASE IF EXISTS `work_user_server`;
CREATE DATABASE `work_user_server` CHARACTER SET `utf8mb4` COLLATE = `utf8mb4_unicode_ci`;
USE `work_user_server`;

-- 项目用户
DROP USER IF EXISTS 'limou'@'%';
CREATE USER 'limou'@'%' IDENTIFIED BY 'Qwe54188_';
GRANT ALL PRIVILEGES ON `work_user_server`.* TO 'limou'@'%';
FLUSH PRIVILEGES;

-- 项目数表
CREATE TABLE `user_role`
(
    `id`          TINYINT   NOT NULL COMMENT '本角色唯一标识(业务层需要考虑使用雪花算法用户标识的唯一性)',
    `name`        VARCHAR(50) COLLATE `utf8mb4_unicode_ci` DEFAULT NULL COMMENT '角色名称',
    `deleted`     TINYINT                                  DEFAULT '0' COMMENT '是否删除(0 为未删除, 1 为已删除)',
    `create_time` TIMESTAMP NULL                           DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(受时区影响)',
    `update_time` TIMESTAMP NULL                           DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间(受时区影响)',
    PRIMARY KEY (`id`) COMMENT '主键'
) ENGINE = InnoDB
  DEFAULT CHARSET = `utf8mb4`
  COLLATE = `utf8mb4_unicode_ci` COMMENT ='用户角色表'
;

CREATE TABLE `user`
(
    `id`          BIGINT UNSIGNED                           NOT NULL AUTO_INCREMENT COMMENT '本用户唯一标识(业务层需要考虑使用雪花算法用户标识的唯一性)',
    `account`     VARCHAR(256) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '账户号(业务层需要决定某一种或多种登录方式, 因此这里不限死为非空)',
    `wx_union`    VARCHAR(256) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '微信号',
    `mp_open`     VARCHAR(256) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '公众号',
    `email`       VARCHAR(256) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '邮箱号',
    `phone`       VARCHAR(20) COLLATE `utf8mb4_unicode_ci`       DEFAULT NULL COMMENT '电话号',
    `ident`       VARCHAR(50) COLLATE `utf8mb4_unicode_ci`       DEFAULT NULL COMMENT '身份证',
    `passwd`      VARCHAR(512) COLLATE `utf8mb4_unicode_ci` NOT NULL COMMENT '用户密码(业务层强制刚刚注册的用户重新设置密码, 交给用户时默认密码为 123456, 并且加盐密码)',
    `avatar`      VARCHAR(1024) COLLATE `utf8mb4_unicode_ci`     DEFAULT NULL COMMENT '用户头像(业务层需要考虑默认头像使用 cos 对象存储)',
    `tags`        VARCHAR(256)                                   DEFAULT NULL COMMENT '用户标签(业务层需要 json 数组格式存储用户标签数组)',
    `nick`        VARCHAR(256) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '用户昵称',
    `name`        VARCHAR(256) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '用户名字',
    `profile`     VARCHAR(512) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '用户简介',
    `birthday`    VARCHAR(512) COLLATE `utf8mb4_unicode_ci`      DEFAULT NULL COMMENT '用户生日',
    `country`     VARCHAR(50) COLLATE `utf8mb4_unicode_ci`       DEFAULT NULL COMMENT '用户国家',
    `address`     TEXT COLLATE `utf8mb4_unicode_ci` COMMENT '用户地址',
    `role`        TINYINT                                        DEFAULT '0' COMMENT '用户角色(业务层需知 -1 为封号, 0 为用户, 1 为管理, ...)',
    `level`       TINYINT                                        DEFAULT '0' COMMENT '用户等级(业务层需知 0 为 level0, 1 为 level1, 2 为 level2, 3 为 level3, ...)',
    `gender`      TINYINT                                        DEFAULT '0' COMMENT '用户性别(业务层需知 0 为未知, 1 为男性, 2 为女性)',
    `deleted`     TINYINT                                        DEFAULT '0' COMMENT '是否删除(0 为未删除, 1 为已删除)',
    `create_time` TIMESTAMP                                 NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(受时区影响)',
    `update_time` TIMESTAMP                                 NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间(受时区影响)',
    PRIMARY KEY (`id`) COMMENT '主键',
    UNIQUE KEY (`account`) COMMENT '唯一',
    KEY `idx_role` (`role`),
    KEY `idx_email` (`email`),
    KEY `idx_user_nick` (`nick`),
    CONSTRAINT `fok_user` FOREIGN KEY (`role`) REFERENCES `user_role` (`id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 27
  DEFAULT CHARSET = `utf8mb4`
  COLLATE = `utf8mb4_unicode_ci` COMMENT ='用户信息表'
;

CREATE TABLE `picture`
(
    `id`             BIGINT UNSIGNED AUTO_INCREMENT COMMENT '本图片唯一标识(业务层需要考虑使用雪花算法用户标识的唯一性)',
    `url`            VARCHAR(512)    NOT NULL COMMENT '图片 url',
    `thumbnail_url`  VARCHAR(512)    NULL COMMENT '缩略图 url',
    `name`           VARCHAR(128)    NOT NULL COMMENT '图片名称',
    `introduction`   VARCHAR(512)    NULL COMMENT '简介',
    `category`       VARCHAR(64)     NULL COMMENT '分类',
    `tags`           VARCHAR(512)    NULL COMMENT '标签(JSON 数组)',
    `pic_size`       BIGINT          NULL COMMENT '图片体积',
    `pic_width`      INT             NULL COMMENT '图片宽度',
    `pic_height`     INT             NULL COMMENT '图片高度',
    `pic_scale`      DOUBLE          NULL COMMENT '图片宽高比例',
    `pic_format`     VARCHAR(32)     NULL COMMENT '图片格式',
    `user_id`        BIGINT UNSIGNED NOT NULL COMMENT '创建用户 id',
    `space_id`       BIGINT               DEFAULT 0 COMMENT '空间 id(为 0 表示公共空间)',
    `review_status`  INT                  DEFAULT 0 NOT NULL COMMENT '审核状态: 0-待审; 1-通过; 2-拒绝',
    `review_message` VARCHAR(512)    NULL COMMENT '审核信息',
    `review_time`    DATETIME        NULL COMMENT '审核时间',
    `reviewer_id`    BIGINT          NULL COMMENT '审核人 ID',
    `deleted`        TINYINT              DEFAULT '0' COMMENT '是否删除(0 为未删除, 1 为已删除)',
    `create_time`    TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(受时区影响)',
    `update_time`    TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间(受时区影响)',
    PRIMARY KEY (`id`) COMMENT '主键',
    INDEX `idx_name` (`name`) COMMENT '提升基于图片名称的查询性能',
    INDEX `idx_introduction` (`introduction`) COMMENT '用于模糊搜索图片简介',
    INDEX `idx_category` (`category`) COMMENT '提升基于分类的查询性能',
    INDEX `idx_tags` (`tags`) COMMENT '提升基于标签的查询性能',
    INDEX `idx_user_id` (`user_id`) COMMENT '提升基于用户 ID 的查询性能',
    INDEX `idx_space_id` (`space_id`) COMMENT '提升基于空间 ID 的查询性能',
    INDEX `idx_review_status` (`review_status`) COMMENT '提升基于审核状态的查询性能'
) ENGINE = InnoDB
  DEFAULT CHARSET = `utf8mb4`
  COLLATE = `utf8mb4_unicode_ci` COMMENT ='图片表'
;

CREATE TABLE IF NOT EXISTS `space`
(
    `id`          BIGINT UNSIGNED AUTO_INCREMENT COMMENT '本空间唯一标识(业务层需要考虑使用雪花算法用户标识的唯一性)',
    `type`        INT     DEFAULT 0 NOT NULL COMMENT '空间类型: 0-公有 1-私有 2-协作',
    `space_name`  VARCHAR(128)      NULL COMMENT '空间名称',
    `space_level` INT     DEFAULT 0 NULL COMMENT '空间级别: 0-普通版 1-专业版 2-旗舰版',
    `max_size`    BIGINT  DEFAULT 0 NULL COMMENT '空间图片的最大总大小',
    `max_count`   BIGINT  DEFAULT 0 NULL COMMENT '空间图片的最大数量',
    `total_size`  BIGINT  DEFAULT 0 NULL COMMENT '当前空间下图片的总大小',
    `total_count` BIGINT  DEFAULT 0 NULL COMMENT '当前空间下的图片数量',
    `user_id`     BIGINT            NOT NULL COMMENT '创建用户 id',
    `deleted`     TINYINT DEFAULT '0' COMMENT '是否删除(0 为未删除, 1 为已删除)',
    `create_time` TIMESTAMP         NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(受时区影响)',
    `update_time` TIMESTAMP         NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间(受时区影响)',
    PRIMARY KEY (`id`) COMMENT '主键',
    INDEX `idx_type` (`type`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_space_name` (`space_name`),
    INDEX `idx_space_level` (`space_level`)
) COLLATE = `utf8mb4_unicode_ci` COMMENT '空间表'
;

-- 项目数据
INSERT INTO `user_role` (`id`, `name`)
VALUES (-1, '封号'),
       (0, '用户'),
       (1, '管理')
;

INSERT INTO `user` (`account`, `wx_union`, `mp_open`, `email`, `phone`, `ident`, `passwd`,
                    `avatar`, `tags`, `nick`, `name`, `profile`, `birthday`, `country`, `address`,
                    `role`, `level`, `gender`, `deleted`)
VALUES ('aimou', 'wx_union_aimou', 'mp_open_aimou', 'aimou@example.com', '13800138001', '370101198701012345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'aimou',
        '艾梦',
        '这是艾梦的个人简介', '1987-01-01', '中国', '北京市朝阳区', 0, 1, 1, 0),
       ('bimou', 'wx_union_bimou', 'mp_open_bimou', 'bimou@example.com', '13800138002', '370101198802022345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'bimou',
        '白萌',
        '这是白萌的个人简介', '1988-02-02', '中国', '上海市浦东新区', 0, 2, 2, 0),
       ('cimou', 'wx_union_cimou', 'mp_open_cimou', 'cimou@example.com', '13800138003', '370101198903032345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'cimou',
        '陈明',
        '这是陈明的个人简介', '1989-03-03', '中国', '广州市天河区', 0, 1, 1, 0),
       ('dimou', 'wx_union_dimou', 'mp_open_dimou', 'dimou@example.com', '13800138004', '370101199004042345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'dimou',
        '邓梅',
        '这是邓梅的个人简介', '1990-04-04', '中国', '深圳市福田区', 0, 1, 2, 0),
       ('eimou', 'wx_union_eimou', 'mp_open_eimou', 'eimou@example.com', '13800138005', '370101199105052345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'eimou',
        '易萌',
        '这是易萌的个人简介', '1991-05-05', '中国', '天津市和平区', 0, 2, 1, 0),
       ('fimou', 'wx_union_fimou', 'mp_open_fimou', 'fimou@example.com', '13800138006', '370101199206062345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'fimou',
        '范敏',
        '这是范敏的个人简介', '1992-06-06', '中国', '北京市海淀区', 0, 1, 2, 0),
       ('gimou', 'wx_union_gimou', 'mp_open_gimou', 'gimou@example.com', '13800138007', '370101199307072345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'gimou',
        '高梅',
        '这是高梅的个人简介', '1993-07-07', '中国', '上海市黄浦区', 0, 1, 1, 0),
       ('himou', 'wx_union_himou', 'mp_open_himou', 'himou@example.com', '13800138008', '370101199408082345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'himou',
        '黄敏',
        '这是黄敏的个人简介', '1994-08-08', '中国', '广州市越秀区', 0, 2, 2, 0),
       ('iimou', 'wx_union_iimou', 'mp_open_iimou', 'iimou@example.com', '13800138009', '370101199509092345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'iimou',
        '冯萌',
        '这是冯萌的个人简介', '1995-09-09', '中国', '深圳市南山区', 0, 1, 1, 0),
       ('jimou', 'wx_union_jimou', 'mp_open_jimou', 'jimou@example.com', '13800138010', '370101199610102345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'jimou',
        '贾梅',
        '这是贾梅的个人简介', '1996-10-10', '中国', '天津市南开区', 0, 2, 2, 0),
       ('kimou', 'wx_union_kimou', 'mp_open_kimou', 'kimou@example.com', '13800138011', '370101199711112345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'kimou',
        '康铭',
        '这是康铭的个人简介', '1997-11-11', '中国', '上海市静安区', 0, 1, 1, 0),
       ('limou', 'wx_union_limou', 'mp_open_limou', 'limou@example.com', '13800138012', '370101199812122345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png',
        '["项目架构师", "后端程序员", "数学爱好者", "运维发烧者"]', 'limou', '李陌', '这是李萌的个人简介', '2004-02-23',
        '中国', '广州市白云区', 1, 1, 1, 0),
       ('mimou', 'wx_union_mimou', 'mp_open_mimou', 'mimou@example.com', '13800138016', '370101200204162345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'mimou',
        '莫敏',
        '这是莫敏的个人简介', '2002-04-16', '中国', '北京市西城区', 0, 1, 1, 0),
       ('nimou', 'wx_union_nimou', 'mp_open_nimou', 'nimou@example.com', '13800138017', '370101200305172345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'nimou',
        '牛梅',
        '这是牛梅的个人简介', '2003-05-17', '中国', '上海市徐汇区', 0, 1, 2, 0),
       ('oimou', 'wx_union_oimou', 'mp_open_oimou', 'oimou@example.com', '13800138018', '370101200406182345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'oimou',
        '欧阳敏',
        '这是欧阳敏的个人简介', '2004-06-18', '中国', '深圳市龙华区', 0, 2, 1, 0),
       ('pimou', 'wx_union_pimou', 'mp_open_pimou', 'pimou@example.com', '13800138019', '370101200507192345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'pimou',
        '潘萌',
        '这是潘萌的个人简介', '2005-07-19', '中国', '广州市花都区', 0, 1, 1, 0),
       ('qimou', 'wx_union_qimou', 'mp_open_qimou', 'qimou@example.com', '13800138020', '370101200608202345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'qimou',
        '曲敏',
        '这是曲敏的个人简介', '2006-08-20', '中国', '上海市杨浦区', 0, 2, 2, 0),
       ('rimou', 'wx_union_rimou', 'mp_open_rimou', 'rimou@example.com', '13800138021', '370101200709212345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'rimou',
        '任梅',
        '这是任梅的个人简介', '2007-09-21', '中国', '天津市武清区', 0, 1, 1, 0),
       ('simou', 'wx_union_simou', 'mp_open_simou', 'simou@example.com', '13800138022', '370101200810222345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'simou',
        '孙萌',
        '这是孙萌的个人简介', '2008-10-22', '中国', '北京市昌平区', 0, 1, 2, 0),
       ('timou', 'wx_union_timou', 'mp_open_timou', 'timou@example.com', '13800138023', '370101200911232345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'timou',
        '陶敏',
        '这是陶敏的个人简介', '2009-11-23', '中国', '上海市宝山区', 0, 1, 1, 0),
       ('uimou', 'wx_union_uimou', 'mp_open_uimou', 'uimou@example.com', '13800138024', '370101201012242345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'uimou',
        '吴梅',
        '这是吴梅的个人简介', '2010-12-24', '中国', '深圳市龙岗区', 0, 2, 2, 0),
       ('vimou', 'wx_union_vimou', 'mp_open_vimou', 'vimou@example.com', '13800138025', '370101201112252345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'vimou',
        '韦敏',
        '这是韦敏的个人简介', '2011-12-25', '中国', '广州市荔湾区', 0, 2, 1, 0),
       ('wimou', 'wx_union_wimou', 'mp_open_wimou', 'wimou@example.com', '13800138026', '370101201212262345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'wimou',
        '魏萌',
        '这是魏萌的个人简介', '2012-12-26', '中国', '上海市虹口区', 0, 1, 1, 0),
       ('ximou', 'wx_union_ximou', 'mp_open_ximou', 'ximou@example.com', '13800138027', '370101201312272345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'ximou',
        '谢敏',
        '这是谢敏的个人简介', '2013-12-27', '中国', '深圳市南山区', 0, 1, 2, 0),
       ('yimou', 'wx_union_yimou', 'mp_open_yimou', 'yimou@example.com', '13800138028', '370101201412282345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'yimou',
        '杨萌',
        '这是杨萌的个人简介', '2014-12-28', '中国', '北京市朝阳区', 0, 1, 1, 0),
       ('zimou', 'wx_union_zimou', 'mp_open_zimou', 'zimou@example.com', '13800138029', '370101201512292345',
        '5be35df1ff07a29e983bcbaef710626f',
        'https://wci-1318277926.cos.ap-guangzhou.myqcloud.com/work-collaborative-images/logo.png', '["tag"]', 'zimou',
        '张敏',
        '这是张敏的个人简介', '2015-12-29', '中国', '上海市浦东新区', 0, 2, 2, 0)
;
