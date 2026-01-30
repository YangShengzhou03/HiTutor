-- HiTutor 家教平台数据库脚本
-- 清理并创建数据库
DROP DATABASE IF EXISTS hitutor;
CREATE DATABASE hitutor CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hitutor;

-- 用户表
CREATE TABLE `sys_user` (
  `id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `username` VARCHAR(50) COMMENT '用户名',
  `password` VARCHAR(255) COMMENT '密码',
  `email` VARCHAR(100) COMMENT '邮箱',
  `phone` VARCHAR(20) COMMENT '手机号',
  `avatar` VARCHAR(255) COMMENT '头像URL',
  `badge` VARCHAR(8) COMMENT '头衔',
  `role` ENUM('admin', 'student', 'tutor') NOT NULL COMMENT '角色',
  `status` ENUM('active', 'inactive') DEFAULT 'active' COMMENT '状态',
  `gender` ENUM('male', 'female') COMMENT '性别',
  `birth_date` DATE COMMENT '出生日期',
  `teaching_experience` INT COMMENT '教学经验',
  `last_login_ip` VARCHAR(45) COMMENT '最后登录IP',
  `last_login_time` DATETIME COMMENT '最后登录时间',
  `points` INT DEFAULT 0 COMMENT '积分余额',
  `is_verified` TINYINT(1) DEFAULT 0 COMMENT '是否已认证',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 科目表
CREATE TABLE `tutor_subjects` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '科目ID',
  `name` VARCHAR(50) NOT NULL COMMENT '科目名称',
  `status` ENUM('active', 'inactive') DEFAULT 'active' COMMENT '状态',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家教科目表';

-- 学生需求表
CREATE TABLE `student_requests` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '需求ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `child_name` VARCHAR(50) COMMENT '孩子称呼',
  `child_grade` VARCHAR(20) COMMENT '孩子年级',
  `subject_id` BIGINT NOT NULL COMMENT '科目ID',
  `subject_name` VARCHAR(50) NOT NULL COMMENT '科目名称',
  `hourly_rate_min` DECIMAL(10,2) COMMENT '最低时薪',
  `hourly_rate_max` DECIMAL(10,2) COMMENT '最高时薪',
  `address` VARCHAR(255) NOT NULL COMMENT '家教地址',
  `latitude` DECIMAL(10,8) NOT NULL COMMENT '纬度',
  `longitude` DECIMAL(11,8) NOT NULL COMMENT '经度',
  `requirements` TEXT COMMENT '教学要求',
  `available_time` VARCHAR(255) COMMENT '可上课时间',
  `status` ENUM('recruiting', 'matched', 'closed', 'completed') DEFAULT 'recruiting' COMMENT '状态',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`latitude`, `longitude`),
  CONSTRAINT `fk_student_request_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_student_request_subject` FOREIGN KEY (`subject_id`) REFERENCES `tutor_subjects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生需求表';

-- 家教信息表
CREATE TABLE `tutor_profiles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '家教信息ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `subject_id` BIGINT NOT NULL COMMENT '科目ID',
  `subject_name` VARCHAR(50) NOT NULL COMMENT '科目名称',
  `hourly_rate` DECIMAL(10,2) NOT NULL COMMENT '时薪',
  `address` VARCHAR(255) NOT NULL COMMENT '授课地址',
  `latitude` DECIMAL(10,8) NOT NULL COMMENT '纬度',
  `longitude` DECIMAL(11,8) NOT NULL COMMENT '经度',
  `description` TEXT COMMENT '描述',
  `available_time` VARCHAR(255) COMMENT '可授课时间',
  `target_grade_levels` VARCHAR(255) DEFAULT NULL COMMENT '目标年级，逗号分隔',
  `status` ENUM('available', 'busy', 'inactive') DEFAULT 'available' COMMENT '状态',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`latitude`, `longitude`),
  CONSTRAINT `fk_tutor_profile_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tutor_profile_subject` FOREIGN KEY (`subject_id`) REFERENCES `tutor_subjects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家教信息表';

-- 预约表
CREATE TABLE `appointments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `tutor_id` VARCHAR(36) NOT NULL COMMENT '家教ID',
  `student_id` VARCHAR(36) NOT NULL COMMENT '学生ID',
  `subject_id` BIGINT NOT NULL COMMENT '科目ID',
  `subject_name` VARCHAR(50) NOT NULL COMMENT '科目名称',
  `appointment_time` DATETIME NOT NULL COMMENT '预约时间',
  `duration` INT NOT NULL COMMENT '时长',
  `address` VARCHAR(255) NOT NULL COMMENT '上课地址',
  `latitude` DECIMAL(10,8) COMMENT '纬度',
  `longitude` DECIMAL(11,8) COMMENT '经度',
  `hourly_rate` DECIMAL(10,2) NOT NULL COMMENT '时薪',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '总金额',
  `status` ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending' COMMENT '状态',
  `notes` TEXT COMMENT '备注',
  `request_id` BIGINT COMMENT '关联的需求/家教信息ID',
  `request_type` ENUM('student_request', 'tutor_profile') COMMENT '关联的类型',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_tutor_id` (`tutor_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_appointment_time` (`appointment_time`),
  KEY `idx_status` (`status`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_request_type` (`request_type`),
  CONSTRAINT `fk_appointment_tutor` FOREIGN KEY (`tutor_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_appointment_student` FOREIGN KEY (`student_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_appointment_subject` FOREIGN KEY (`subject_id`) REFERENCES `tutor_subjects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预约表';



-- 评价表
CREATE TABLE `reviews` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `appointment_id` BIGINT NOT NULL COMMENT '预约ID',
  `reviewer_id` VARCHAR(36) NOT NULL COMMENT '评价人ID',
  `reviewed_id` VARCHAR(36) NOT NULL COMMENT '被评价人ID',
  `rating` INT NOT NULL COMMENT '评分',
  `comment` TEXT COMMENT '评价内容',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_appointment_reviewer` (`appointment_id`, `reviewer_id`),
  KEY `idx_appointment_id` (`appointment_id`),
  KEY `idx_reviewer_id` (`reviewer_id`),
  KEY `idx_reviewed_id` (`reviewed_id`),
  KEY `idx_rating` (`rating`),
  CONSTRAINT `fk_review_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评价表';

-- 投诉表
CREATE TABLE `complaints` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '投诉ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '投诉人ID',
  `target_user_id` VARCHAR(36) NOT NULL COMMENT '被投诉用户ID',
  `category_name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `type_text` VARCHAR(50) NOT NULL COMMENT '投诉类型',
  `description` TEXT NOT NULL COMMENT '投诉说明',
  `contact_phone` VARCHAR(20) COMMENT '联系电话',
  `status` ENUM('pending', 'processing', 'resolved', 'rejected') DEFAULT 'pending' COMMENT '状态',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_target_user_id` (`target_user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_complaint_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_complaint_target_user` FOREIGN KEY (`target_user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='投诉表';

-- 报名申请表
CREATE TABLE `request_applications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '申请ID',
  `request_id` BIGINT NOT NULL COMMENT '需求ID',
  `request_type` ENUM('student_request', 'tutor_profile') NOT NULL COMMENT '请求类型',
  `applicant_id` VARCHAR(36) NOT NULL COMMENT '申请人ID',
  `applicant_name` VARCHAR(50) NOT NULL COMMENT '申请人姓名',
  `applicant_phone` VARCHAR(20) COMMENT '申请人手机号',
  `message` TEXT COMMENT '申请留言',
  `status` ENUM('pending', 'accepted', 'confirmed', 'rejected', 'cancelled') DEFAULT 'pending' COMMENT '状态',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_request_applicant` (`request_id`, `applicant_id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_applicant_id` (`applicant_id`),
  KEY `idx_request_type` (`request_type`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_application_applicant` FOREIGN KEY (`applicant_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报名申请表';

-- 收藏表
CREATE TABLE `favorites` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `target_id` BIGINT NOT NULL COMMENT '目标ID',
  `target_type` ENUM('tutor_profile', 'student_request') NOT NULL COMMENT '目标类型',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target` (`user_id`, `target_id`, `target_type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_target_id` (`target_id`),
  KEY `idx_target_type` (`target_type`),
  CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

-- 黑名单表
CREATE TABLE `blacklist` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '黑名单ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `blocked_user_id` VARCHAR(36) NOT NULL COMMENT '被拉黑用户ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_blocked` (`user_id`, `blocked_user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_blocked_user_id` (`blocked_user_id`),
  CONSTRAINT `fk_blacklist_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_blacklist_blocked_user` FOREIGN KEY (`blocked_user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='黑名单表';

-- 会话表
CREATE TABLE `conversations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user1_id` VARCHAR(36) NOT NULL COMMENT '用户1 ID',
  `user2_id` VARCHAR(36) NOT NULL COMMENT '用户2 ID',
  `last_message_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后消息时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users` (`user1_id`, `user2_id`),
  KEY `idx_user1_id` (`user1_id`),
  KEY `idx_user2_id` (`user2_id`),
  KEY `idx_last_message_time` (`last_message_time`),
  CONSTRAINT `fk_conversation_user1` FOREIGN KEY (`user1_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversation_user2` FOREIGN KEY (`user2_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会话表';

-- 积分记录表
CREATE TABLE `point_records` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '积分记录ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `points` INT NOT NULL COMMENT '积分变化（正数为增加，负数为减少）',
  `type` VARCHAR(50) NOT NULL COMMENT '积分类型（register, login, appointment, review, etc.）',
  `description` VARCHAR(255) COMMENT '积分说明',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_point_record_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分记录表';

-- 家教简历表
CREATE TABLE `tutor_resumes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '简历ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `teaching_experience` INT COMMENT '教学年限',
  `teaching_style` TEXT COMMENT '教学风格',
  `specialties` TEXT COMMENT '擅长科目',
  `achievements` TEXT COMMENT '教学成就',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_tutor_resume_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家教简历表';

-- 家教认证表
CREATE TABLE `tutor_certifications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '认证ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `real_name` VARCHAR(50) NOT NULL COMMENT '真实姓名',
  `id_card` VARCHAR(18) NOT NULL COMMENT '身份证号',
  `education` ENUM('初中及以下', '高中', '大专', '本科', '硕士', '博士及以上') COMMENT '学历',
  `school` VARCHAR(100) NOT NULL COMMENT '毕业院校',
  `major` VARCHAR(50) NOT NULL COMMENT '专业',
  `certificate_number` VARCHAR(50) COMMENT '教师资格证号',
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' COMMENT '认证状态',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_tutor_certification_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家教认证表';

-- 消息通知表
CREATE TABLE `notifications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` VARCHAR(36) NOT NULL COMMENT '用户ID',
  `type` VARCHAR(50) NOT NULL COMMENT '通知类型（application, appointment, review, system, etc.）',
  `title` VARCHAR(200) NOT NULL COMMENT '通知标题',
  `content` TEXT COMMENT '通知内容',
  `related_id` VARCHAR(36) COMMENT '关联ID（如申请ID、订单ID等）',
  `related_type` VARCHAR(50) COMMENT '关联类型（application, appointment, review, etc.）',
  `is_read` TINYINT(1) DEFAULT 0 COMMENT '是否已读',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_user_read` (`user_id`, `is_read`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息通知表';

-- 插入初始科目数据
INSERT INTO `tutor_subjects` (`name`) VALUES
('语文'),
('数学'),
('英语'),
('物理'),
('化学'),
('生物'),
('历史'),
('地理'),
('政治'),
('音乐'),
('美术'),
('体育');

-- 插入管理员账户
INSERT INTO `sys_user` (`id`, `username`, `password`, `email`, `role`, `status`, `is_verified`) VALUES
('5bb98ebf-1408-40f1-9d4d-3d1f4932f386', 'admin', '123456', 'admin@qq.com', 'admin', 'active', 0);
