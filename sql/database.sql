CREATE SCHEMA WEGROW COLLATE UTF8MB4_UNICODE_CI;

USE WEGROW;

DROP TABLE IF EXISTS USER;

CREATE TABLE USER
(
    ID          INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    EMAIL       VARCHAR(64) NULL COMMENT '用户邮箱',
    USERNAME    VARCHAR(20) NOT NULL COMMENT '用户昵称',
    ABOUT_ME    VARCHAR(100)         DEFAULT '该用户很懒还没有简介~' COMMENT '用户简介',
    LAST_SEEN   DATETIME COMMENT '用户最后一次登陆时间',
    CREATE_TIME DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    AVATAR_HASH MEDIUMTEXT  NULL COMMENT '用户头像HASH',
    CONSTRAINT EMAIL UNIQUE (EMAIL),
    CONSTRAINT USERNAME UNIQUE (USERNAME)
);

CREATE TABLE RESOURCE
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    CREATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    URL         VARCHAR(50)  NOT NULL COMMENT '资源URL',
    DESCRIPTION varchar(100) NOT NULL COMMENT '资源描述'
);

CREATE TABLE USERS_EXTENDS
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT          NOT NULL COMMENT '用户ID',
    FIELD       VARCHAR(20)  NOT NULL COMMENT '信息扩展字段',
    VALUE       VARCHAR(100) NULL COMMENT '扩展字段值',
    CREATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT FK_USERID FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT UNIQUE_KEYS UNIQUE (USER_ID, FIELD)
);

CREATE TABLE LOCAL_AUTH
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT          NOT NULL COMMENT '用户ID',
    PASSWORD    VARCHAR(100) NOT NULL COMMENT '用户密码',
    CREATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT USER_ID UNIQUE (USER_ID),
    CONSTRAINT FK_LOCAL_AUTH FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE
);

CREATE TABLE O_AUTH
(
    ID                 INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID            INT         NOT NULL COMMENT '用户ID',
    OAUTH_NAME         VARCHAR(20) NOT NULL COMMENT 'OAUTH登陆类型',
    OAUTH_ID           VARCHAR(50) NOT NULL COMMENT '第三方认证ID',
    OAUTH_ACCESS_TOKEN VARCHAR(50) NOT NULL COMMENT '第三方认证TOKEN',
    CREATE_TIME        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT FK_O_AUTH FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT USER_ID UNIQUE (USER_ID)
);

CREATE TABLE FOLLOW
(
    ID               INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID          INT      NOT NULL COMMENT '用户ID',
    FOLLOWED_USER_ID INT      NOT NULL COMMENT '用户关注的人的ID',
    STATUS           INT               DEFAULT 1 COMMENT '关注状态:是否取消关注等',
    CREATE_TIME      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME      DATETIME NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USERID_3 FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT FK_USERID_4 FOREIGN KEY (FOLLOWED_USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT UNIQUE_USERS UNIQUE (USER_ID, FOLLOWED_USER_ID)
);

CREATE TABLE TOPIC
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT          NOT NULL COMMENT '所属者ID',
    TOPIC_NAME  VARCHAR(64)  NOT NULL COMMENT '专题名字',
    TOPIC_INFO  VARCHAR(100) NOT NULL COMMENT '专题简介',
    STATUS      INT                   DEFAULT 1 NOT NULL COMMENT '专题状态',
    AVATAR_HASH VARCHAR(100) NULL COMMENT '专题介绍图片HASH',
    CREATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME DATETIME     NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT TOPIC_NAME UNIQUE (TOPIC_NAME),
    CONSTRAINT TOPIC_IBFK_1 FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE
);

CREATE TABLE BLOCK
(
    ID            INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID       INT        NOT NULL,
    TITLE         VARCHAR(30) COMMENT '用户创建的内容名称',
    BLOCK_CONTENT LONGTEXT COMMENT '用户创建的内容',
    BLOCK_IMAGE   MEDIUMTEXT NULL COMMENT '题图HASH',
    UPDATE_TIME   DATETIME   NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CREATE_TIME   DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    STATUS        INT                 DEFAULT 1 COMMENT '文章状态:0：封禁，1: 可用，2：尚未发布，3：被删除',
    TOPIC_ID      INT        NOT NULL COMMENT '所属的专题ID',
    CONSTRAINT CATEGORY_IBFK_1 FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT CATEGORY_IBFK_2 FOREIGN KEY (TOPIC_ID) REFERENCES TOPIC (ID) ON DELETE CASCADE
);

CREATE TABLE BLOCK_EXTENDS
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    BLOCK_ID    INT          NOT NULL COMMENT '用户ID',
    FIELD       VARCHAR(20)  NOT NULL COMMENT '信息扩展字段',
    VALUE       VARCHAR(100) NULL COMMENT '扩展字段值',
    CREATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT FK_BLOCKID FOREIGN KEY (BLOCK_ID) REFERENCES BLOCK (ID) ON DELETE CASCADE,
    CONSTRAINT UNIQUE_KEYS UNIQUE (BLOCK_ID, FIELD)
);

CREATE TABLE NOTIFY
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    CONTENT     TEXT        NOT NULL COMMENT '消息的内容',
    TYPE        TINYINT     NOT NULL COMMENT '消息类型（公告，提醒，私信）',
    TARGET_ID   INT         NOT NULL COMMENT '目标的ID：对应表对象的ID',
    TARGET_TYPE VARCHAR(20) NOT NULL COMMENT '目标的类型: 例如：文章、专区（表名）',
    ACTION      TINYINT     NOT NULL COMMENT '动作类型：例如点赞',
    SENDER_ID   INT         NOT NULL COMMENT '发送者ID',
    IS_READ     TINYINT     NOT NULL DEFAULT 0 COMMENT '阅读状态',
    USER_ID     INT         NOT NULL COMMENT '接收者ID',
    CREATE_TIME DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME DATETIME    NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT NOTIFY_IBFK_1 FOREIGN KEY (SENDER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT NOTIFY_IBFK_2 FOREIGN KEY (USER_ID) REFERENCES TOPIC (ID) ON DELETE CASCADE
);

CREATE TABLE ROLES
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    NAME        VARCHAR(20) NOT NULL COMMENT '角色名称',
    STATUS      TINYINT(1)           DEFAULT 1 NOT NULL COMMENT '是否启用',
    CREATE_TIME DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME DATETIME    NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT NAME UNIQUE (NAME)
);

CREATE TABLE PERMISSION
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    NAME        VARCHAR(50)        NOT NULL COMMENT '权限名称',
    ACTION      VARCHAR(50)        NOT NULL COMMENT '权限行为说明',
    STATUS      INT      DEFAULT 1 NOT NULL COMMENT '是否启用',
    CREATE_TIME DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT NAME UNIQUE (NAME),
    CONSTRAINT ACTION UNIQUE (ACTION)
);

CREATE TABLE USER_ROLE_MAP
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT      NOT NULL COMMENT '用户ID',
    ROLE_ID     INT      NOT NULL COMMENT '角色ID',
    STATUS      INT               DEFAULT 1 COMMENT '该用户当前角色的状态',
    CREATE_TIME DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME DATETIME NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USER_ROLE_MAP FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT FK_USER_ROLE_MAP_1 FOREIGN KEY (ROLE_ID) REFERENCES ROLES (ID) ON DELETE CASCADE,
    CONSTRAINT UNIQUE_KEYS UNIQUE (USER_ID, ROLE_ID)
);

CREATE TABLE ROLE_PERMISSION_MAP
(
    ID            INT AUTO_INCREMENT PRIMARY KEY,
    ROLE_ID       INT      NOT NULL COMMENT '角色ID',
    PERMISSION_ID INT      NOT NULL COMMENT '权限ID',
    CREATE_TIME   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME   DATETIME NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USER_PERMISSION_MAP FOREIGN KEY (ROLE_ID) REFERENCES ROLES (ID) ON DELETE CASCADE,
    CONSTRAINT FK_USER_PERMISSION_MAP_1 FOREIGN KEY (PERMISSION_ID) REFERENCES PERMISSION (ID) ON DELETE CASCADE,
    CONSTRAINT UNIQUE_KEYS UNIQUE (ROLE_ID, PERMISSION_ID)
);

-- 文章评论表
CREATE TABLE COMMENT
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT         NOT NULL COMMENT '用户ID',
    TARGET_TYPE VARCHAR(20) NOT NULL COMMENT '目标类型：具体针对哪个业务评论（目标表名）',
    TARGET_ID   INT         NOT NULL COMMENT '目标表对应的ID',
    CONTENT     VARCHAR(50) NOT NULL COMMENT '内容',
    STATUS      BOOLEAN     NOT NULL DEFAULT 0 COMMENT '0是未删除，1删除',
    CREATE_TIME DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME DATETIME    NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USER_COMMENT FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE
);

CREATE TABLE REPLY
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    COMMENT_ID  INT         NOT NULL COMMENT '评论表ID',
    CONTENT     VARCHAR(50) NOT NULL COMMENT '内容',
    USER_ID     INT         NOT NULL COMMENT '用户ID',
    STATUS      BOOLEAN     NOT NULL DEFAULT 0 COMMENT '0是未删除，1删除',
    CREATE_TIME DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    REPLY_ID    INT         NOT NULL COMMENT '回复用户ID',
    UPDATE_TIME DATETIME    NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_REPLIED_USER_COMMENT FOREIGN KEY (USER_ID) REFERENCES USER (ID) ON DELETE CASCADE,
    CONSTRAINT FK_REPLY_USER_COMMENT FOREIGN KEY (REPLY_ID) REFERENCES USER (ID) ON DELETE CASCADE
);

-- 评论关系记录表
CREATE TABLE BLOCK_PARENT_CHILD_MAP
(
    ID
        INT
        AUTO_INCREMENT
        PRIMARY
            KEY,
    PARENT_ID
        INT
        NOT
            NULL
        COMMENT
            '评论ID',
    CHILD_ID
        INT
        NOT
            NULL
        COMMENT
            '回复ID',
    CONSTRAINT
        FK_PARENT_COMMENT
        FOREIGN
            KEY
            (
             PARENT_ID
                ) REFERENCES BLOCK_COMMENT
            (
             ID
                ) ON DELETE CASCADE,
    CONSTRAINT FK_CHILD_COMMENT FOREIGN KEY
        (
         CHILD_ID
            ) REFERENCES BLOCK_COMMENT
            (
             ID
                )
        ON DELETE CASCADE
);


-- 权限对应的是可以在URL中加参数对模型进行处理
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('USER_LOGIN', '仅有登录权限', true);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('BLOCK_CREATE', '创建文章权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('BLOCK_DELETE', '删除文章权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('BLOCK_UPDATE', '更新文章权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('COMMENT_CREATE', '创建评论权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('COMMENT_DELETE', '删除评论权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('COMMENT_UPDATE', '更新评论权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('TOPIC_CREATE', '创建专题权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('TOPIC_DELETE', '删除专题权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('TOPIC_UPDATE', '更新专题权限', TRUE);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('USER_CREATE', '创建用户权限', true);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('USER_DELETE', '删除用户权限', true);
INSERT PERMISSION (NAME, ACTION, STATUS)
VALUES ('USER_UPDATE', '更新用户权限', true);

INSERT ROLES (NAME, STATUS)
VALUES ('BAN_USER', TRUE);
INSERT ROLES (NAME, STATUS)
VALUES ('ESTOPPEL_USER', TRUE);
INSERT ROLES (NAME, STATUS)
VALUES ('ORDINARY_USER', TRUE);
INSERT ROLES (NAME, STATUS)
VALUES ('ADMIN_USER', TRUE);

INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (2, 1);

INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (3, 1);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (3, 2);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (3, 3);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (3, 4);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (3, 5);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (3, 6);

INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 1);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 2);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 3);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 4);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 5);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 6);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 7);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 8);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 9);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 10);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 11);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 12);
INSERT ROLE_PERMISSION_MAP (ROLE_ID, PERMISSION_ID)
VALUES (4, 13);
