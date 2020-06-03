CREATE SCHEMA WEGROW COLLATE UTF8MB4_UNICODE_CI;

USE WEGROW;

DROP TABLE IF EXISTS USER;

CREATE TABLE USERS
(
    ID          INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    EMAIL       VARCHAR(64)  NULL COMMENT '用户邮箱',
    USERNAME    VARCHAR(20)  NOT NULL COMMENT '用户昵称',
    ABOUT_ME    VARCHAR(100) NULL COMMENT '用户简介',
    LAST_SEEN   DATETIME     NOT NULL COMMENT '用户最后一次登陆时间',
    CREATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    AVATAR_HASH VARCHAR(100) NULL COMMENT '用户头像HASH',
    STATUS      TINYINT COMMENT '用户状态信息：是否被封禁，是否进行邮件验证',
    CONSTRAINT EMAIL UNIQUE (EMAIL),
    CONSTRAINT USERNAME UNIQUE (USERNAME)
);

DROP TABLE IF EXISTS USERS_EXTENDS;

CREATE TABLE USERS_EXTENDS
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT          NOT NULL COMMENT '用户ID',
    FIELD       VARCHAR(20)  NOT NULL COMMENT '信息扩展字段',
    VALUE       VARCHAR(100) NULL COMMENT '扩展字段值',
    CREATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT FK_USERID FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
);

CREATE TABLE LOCAL_AUTH
(
    ID            INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID       INT          NOT NULL COMMENT '用户ID',
    EMAIL         VARCHAR(50)  NOT NULL COMMENT '用户邮箱',
    PASSWORD_HASH VARCHAR(100) NOT NULL COMMENT '用户密码',
    CREATE_TIME   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT EMAIL UNIQUE (EMAIL),
    CONSTRAINT FK_LOCAL_AUTH FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
);

CREATE TABLE O_AUTH
(
    ID                 INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID            INT         NOT NULL COMMENT '用户ID',
    O_AUTH_NAME        VARCHAR(20) NOT NULL COMMENT 'OAUTH登陆类型',
    OAUTH_ID           VARCHAR(50) NOT NULL COMMENT '第三方认证ID',
    OAUTH_ACCESS_TOKEN VARCHAR(50) NOT NULL COMMENT '第三方认证TOKEN',
    CREATE_TIME        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT FK_O_AUTH FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
);

CREATE TABLE FOLLOW
(
    ID               INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID          INT       NOT NULL COMMENT '用户ID',
    FOLLOWED_USER_ID INT       NOT NULL COMMENT '用户关注的人的ID',
    STATUS           TINYINT COMMENT '关注状态:是否取消关注等',
    CREATE_TIME      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME      TIMESTAMP NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USERID_3 FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
    CONSTRAINT FK_USERID_4 FOREIGN KEY (FOLLOWED_USER_ID) REFERENCES USERS (ID)
);

CREATE TABLE TOPIC
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT          NOT NULL COMMENT '所属者ID',
    TOPIC_NAME  VARCHAR(64)  NOT NULL COMMENT '专题名字',
    TOPIC_INFO  VARCHAR(100) NOT NULL COMMENT '专题简介',
    STATUS      TINYINT      NOT NULL COMMENT '专题状态',
    AVATAR_HASH VARCHAR(100) NULL COMMENT '专题介绍图片HASH',
    CREATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME TIMESTAMP    NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT TOPIC_NAME UNIQUE (TOPIC_NAME),
    CONSTRAINT TOPIC_IBFK_1 FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
);

CREATE TABLE BLOCK
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT         NOT NULL,
    TITLE       VARCHAR(30) NOT NULL COMMENT '用户创建的内容名称',
    CONTENT     LONGTEXT    NOT NULL COMMENT '用户创建的内容',
    UPDATE_TIME TIMESTAMP   NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CREATE_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    STATUS      TINYINT COMMENT '文章状态:是否被封禁',
    TOPIC_ID    INT         NOT NULL COMMENT '所属的专题ID',
    CONSTRAINT CATEGORY_IBFK_1 FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
    CONSTRAINT CATEGORY_IBFK_2 FOREIGN KEY (TOPIC_ID) REFERENCES TOPIC (ID)
);

CREATE TABLE BLOCK_EXTENDS
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    BLOCK_ID    INT          NOT NULL COMMENT '用户ID',
    FIELD       VARCHAR(20)  NOT NULL COMMENT '信息扩展字段',
    VALUE       VARCHAR(100) NULL COMMENT '扩展字段值',
    CREATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '信息创建时间',
    UPDATE_TIME TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息更新时间',
    CONSTRAINT FK_BLOCKID FOREIGN KEY (BLOCK_ID) REFERENCES BLOCK (ID)
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
    CREATE_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME TIMESTAMP   NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT NOTIFY_IBFK_1 FOREIGN KEY (SENDER_ID) REFERENCES USERS (ID),
    CONSTRAINT NOTIFY_IBFK_2 FOREIGN KEY (USER_ID) REFERENCES TOPIC (ID)
);

CREATE TABLE ROLES
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    NAME        VARCHAR(20) NOT NULL COMMENT '角色名称',
    STATUS      TINYINT(1)  NOT NULL COMMENT '是否启用',
    CREATE_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME TIMESTAMP   NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

CREATE TABLE PERMISSION
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    NAME        VARCHAR(50) NOT NULL COMMENT '权限名称',
    ACTION      TINYINT     NOT NULL COMMENT '权限行为属性值',
    STATUS      TINYINT(1)  NOT NULL COMMENT '是否启用',
    CREATE_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME TIMESTAMP   NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);


CREATE TABLE USER_ROLE_MAP
(
    ID          INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     INT       NOT NULL COMMENT '用户ID',
    ROLE_ID     INT       NOT NULL COMMENT '角色ID',
    STATUS      TINYINT COMMENT '该用户当前角色的状态',
    CREATE_TIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME TIMESTAMP NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USER_ROLE_MAP FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
    CONSTRAINT FK_USER_ROLE_MAP_1 FOREIGN KEY (ROLE_ID) REFERENCES ROLES (ID)
);

CREATE TABLE ROLE_PERMISSION_MAP
(
    ID            INT AUTO_INCREMENT PRIMARY KEY,
    ROLE_ID       INT       NOT NULL COMMENT '角色ID',
    PERMISSION_ID INT       NOT NULL COMMENT '权限ID',
    CREATE_TIME   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME   TIMESTAMP NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT FK_USER_PERMISSION_MAP FOREIGN KEY (ROLE_ID) REFERENCES ROLES (ID),
    CONSTRAINT FK_USER_PERMISSION_MAP_1 FOREIGN KEY (PERMISSION_ID) REFERENCES PERMISSION (ID)
);