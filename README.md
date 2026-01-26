# HiTutor好会帮 —— 家教信息对接平台

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/YangShengzhou03/HiTutor?style=for-the-badge&logo=github)](https://github.com/YangShengzhou03/HiTutor/stargazers)&nbsp;[![GitHub forks](https://img.shields.io/github/forks/YangShengzhou03/HiTutor?style=for-the-badge&logo=github)](https://github.com/YangShengzhou03/HiTutor/network/members)&nbsp;[![GitHub issues](https://img.shields.io/github/issues/YangShengzhou03/HiTutor?style=for-the-badge&logo=github)](https://github.com/YangShengzhou03/HiTutor/issues)&nbsp;[![GitHub license](https://img.shields.io/github/license/YangShengzhou03/HiTutor?style=for-the-badge)](https://github.com/YangShengzhou03/HiTutor/blob/main/LICENSE)&nbsp;[![Flutter](https://img.shields.io/badge/Flutter-3.2.6-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)&nbsp;[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.1.0-6DB33F?style=for-the-badge&logo=springboot)](https://spring.io/projects/spring-boot)

<div align="center">
  <img src="https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/logo.svg" alt="HiTutor Logo" width="120" height="120">
  <h3>一个现代化的家教信息对接共享平台，采用前后端分离架构</h3>
</div>

[快速开始](#快速开始) • [功能特性](#功能特性) • [技术架构](#技术架构) • [API文档](API_RESPONSE_FORMAT.md)

</div>

## 项目简介

HiTutor好会帮是一个纯公益的家教信息对接共享平台，连接学生与专业家教老师。平台仅提供家教信息发布、搜索、对接、沟通等中介信息服务，不提供任何家教教学，不参与任何教学辅导、培训等相关活动。平台提供移动端客户端和后端API接口，通过信息匹配、在线沟通、预约对接、评价反馈等全流程数字化信息服务，提升家教信息对接的透明度和信息质量，降低双方的沟通和匹配成本。

## 功能特性

### 移动客户端功能

**用户认证** - 手机号注册登录、密码登录、短信验证码登录、实名认证、家教教师资质认证

**家教信息** - 发布家教信息、设置授课科目、时薪价格、授课地点、可授课时间段
![发布家教信息](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/publish_tutor_service_page.jpg)

**学生需求** - 发布家教需求、选择辅导科目、设置学生年级、时薪预算、上课地点
![发布学生需求](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/publish_student_request_page.jpg)

**智能搜索** - 按科目筛选、按年级筛选、基于地理位置的附近搜索、按时薪范围筛选、关键词搜索
![地图页面](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/map_page.jpg)

**在线沟通** - 用户间即时聊天、聊天会话管理、消息实时推送、支持文字和图片消息

**预约报名** - 对家教信息/学生需求发起报名、报名状态跟踪、预约时间确认

**预约管理** - 预约信息查看、预约状态管理、预约历史记录、预约取消和完成确认

**评价系统** - 完成对接后评价、1-5星评分、文字评价、评价历史记录

**收藏功能** - 收藏家教信息/学生需求、收藏列表管理、收藏状态实时同步

**黑名单** - 添加用户到黑名单、黑名单列表管理、黑名单用户隔离

**积分系统** - 积分获取和消耗、积分余额查看、积分明细记录
![积分页面](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/points_page.jpg)

**投诉举报** - 用户投诉功能、投诉分类、投诉进度查看

**消息通知** - 系统消息推送、报名申请通知、预约状态变更通知、消息已读/未读管理

**用户主页** - 个人信息展示、已发布信息/需求列表、评价记录、积分信息
![我的页面](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/profile_page.jpg)

## 页面展示

### 首页
**首页** - 展示平台主要功能入口，包括家教信息、学生需求、搜索功能等
![首页](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/home_page.jpg)

### 启动页面
**启动页面** - 应用启动时展示的欢迎页面
![启动页面](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/splash_page.jpg)

### 学生需求详情
**学生需求详情** - 查看学生发布的家教需求详细信息
![学生需求详情](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/student_request_detail_page.jpg)

### 家教认证
**家教认证** - 家教教师资质认证流程，包括填写认证信息、提交材料、审核等步骤
![家教认证表单](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/tutor_certification_form_page.jpg)

**认证状态** - 家教认证通过后显示已认证状态
![家教已认证](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/tutor_certified_page.jpg)

**认证证书** - 家教认证通过后获得的电子版认证证书
![家教认证证书](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/tutor_certification_certificate.jpg)

**认证提交成功** - 提交认证信息后显示的成功提示页面
![认证提交成功](https://gitee.com/Yangshengzhou/hi-tutor/blob/master/assest/certification_submitted_successfully.jpg)

## 快速开始

### 环境要求

#### 开发环境
- **Java**: 17.0+ (后端开发)
- **Flutter SDK**: 3.2.6+ (移动客户端开发)
- **Dart SDK**: 3.2.6+ (移动客户端开发)
- **MySQL**: 8.0+ (数据库)
- **Maven**: 3.6+ (后端构建)

#### 生产环境
- **服务器**: Linux/Windows Server
- **内存**: 4GB+ RAM
- **存储**: 2GB+ 可用空间

## 安装部署

### 1. 克隆项目
```bash
git clone https://github.com/YangShengzhou03/HiTutor.git
cd HiTutor
```

### 2. 数据库配置

#### 配置数据库
```sql
-- 创建数据库
CREATE DATABASE hitutor CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 执行初始化脚本
USE hitutor;
SOURCE data.sql;
```

### 3. 后端部署

#### 配置应用
编辑 `hitutor-backend/src/main/resources/application.yml`：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/hitutor?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password

app:
  jwt:
    secret: hitutor-secret-key-for-jwt-token-generation
    expiration: 86400000

server:
  port: 8080
```

#### 启动后端服务
```bash
cd hitutor-backend

# 编译项目
mvn clean package

# 运行应用
java -jar target/hitutor-backend-1.0.0.jar
```

### 4. 移动客户端部署

#### 安装依赖
```bash
cd client
flutter pub get
```

#### 配置API地址
编辑 `client/lib/services/api_service.dart`：
```dart
class ApiService {
  static const String baseUrl = 'http://your-server-ip:8080/api';
  // ...
}
```

#### 运行应用
```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome
```

## 技术架构

### 系统架构图
```
┌─────────────────┐    ┌─────────────────┐
│   移动客户端     │    │   后端API层     │
│                 │    │                 │
│  Flutter 3.2.6   │◄──►│ Spring Boot 3.1.0 │
│  Dart 3.2.6     │    │  MyBatis Plus  │
│                 │    │                 │
└─────────────────┘    └─────────────────┘
         │                        │
         │                        │
         ▼                        ▼
┌─────────────────┐    ┌─────────────────┐
│   用户交互层     │    │   数据存储层     │
│                 │    │                 │
│  组件化开发     │    │   MySQL 8.0     │
│  Provider状态管理│    │   数据持久化     │
└─────────────────┘    └─────────────────┘
```

### 技术栈详情

#### 移动客户端技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.2.6 | 跨平台移动应用框架 |
| Dart | 3.2.6 | 编程语言 |
| Provider | 6.1.0 | 状态管理 |
| HTTP | 1.1.0 | HTTP客户端 |
| Shared Preferences | 2.2.3 | 本地存储 |
| AMap Flutter Map | 3.0.0 | 高德地图 |
| Geolocator | 11.1.0 | 地理位置 |
| Permission Handler | 11.0.0 | 权限管理 |
| Intl | 0.19.0 | 国际化 |

#### 后端技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| Spring Boot | 3.1.0 | Java企业级开发框架 |
| MyBatis Plus | 3.5.4.1 | 数据持久层框架 |
| MySQL | 8.0.33 | 关系型数据库 |
| Maven | 3.6+ | 项目构建工具 |
| Java | 17 | 开发语言 |
| JWT | 0.11.5 | JSON Web Token认证 |
| WebSocket | - | 实时通信 |

### 项目结构

```
HiTutor/
├── client/                              # 移动客户端项目
│   ├── lib/                             # 源代码
│   │   ├── models/                      # 数据模型
│   │   │   ├── user_model.dart
│   │   │   ├── tutor_model.dart
│   │   │   └── message_model.dart
│   │   ├── pages/                       # 页面组件
│   │   │   ├── auth/                    # 认证页面
│   │   │   │   ├── password_login_page.dart
│   │   │   │   ├── sms_login_page.dart
│   │   │   │   ├── role_selection_page.dart
│   │   │   │   └── forgot_password_page.dart
│   │   │   ├── main/                    # 主页面
│   │   │   │   ├── home_page.dart
│   │   │   │   ├── discover_page.dart
│   │   │   │   ├── message_page.dart
│   │   │   │   ├── profile_page.dart
│   │   │   │   ├── main_tab_page.dart
│   │   │   │   └── splash_page.dart
│   │   │   ├── tutor/                   # 家教相关页面
│   │   │   │   └── tutor_detail_page.dart
│   │   │   ├── student_request/          # 学生需求页面
│   │   │   │   └── student_request_detail_page.dart
│   │   │   ├── publish/                 # 发布页面
│   │   │   │   ├── publish_tutor_service_page.dart
│   │   │   │   └── publish_student_request_page.dart
│   │   │   ├── chat/                    # 聊天页面
│   │   │   │   └── chat_detail_page.dart
│   │   │   ├── appointment/             # 预约页面
│   │   │   │   ├── appointment_page.dart
│   │   │   │   └── create_appointment_page.dart
│   │   │   ├── application/             # 报名页面
│   │   │   │   ├── application_list_page.dart
│   │   │   │   ├── application_detail_page.dart
│   │   │   │   ├── application_form_page.dart
│   │   │   │   └── my_applications_page.dart
│   │   │   ├── services/                # 信息页面
│   │   │   │   ├── favorites_page.dart
│   │   │   │   ├── my_publishings_page.dart
│   │   │   │   ├── my_reviews_page.dart
│   │   │   │   ├── points_page.dart
│   │   │   │   ├── points_detail_page.dart
│   │   │   │   ├── tutor_certification_page.dart
│   │   │   │   ├── tutor_resume_page.dart
│   │   │   │   └── customer_service_page.dart
│   │   │   ├── settings/                # 设置页面
│   │   │   │   ├── settings_page.dart
│   │   │   │   ├── profile_edit_page.dart
│   │   │   │   ├── account_security_page.dart
│   │   │   │   ├── change_phone_page.dart
│   │   │   │   ├── change_email_page.dart
│   │   │   │   └── blacklist_page.dart
│   │   │   ├── notification/             # 通知页面
│   │   │   │   └── notification_page.dart
│   │   │   ├── review/                  # 评价页面
│   │   │   │   └── review_page.dart
│   │   │   ├── about/                   # 关于页面
│   │   │   │   ├── about_us_page.dart
│   │   │   │   ├── user_agreement_page.dart
│   │   │   │   ├── privacy_policy_page.dart
│   │   │   │   ├── complaint_page.dart
│   │   │   │   └── complaint_list_page.dart
│   │   │   ├── user/                   # 用户页面
│   │   │   │   └── user_profile_page.dart
│   │   │   ├── subject/                 # 科目页面
│   │   │   │   └── subject_explore_page.dart
│   │   │   ├── map/                    # 地图页面
│   │   │   │   └── map_page.dart
│   │   │   └── tutor_service/           # 家教服务页面
│   │   │       └── tutor_service_detail_page.dart
│   │   ├── providers/                   # 状态管理
│   │   │   ├── auth_provider.dart
│   │   │   ├── tutor_provider.dart
│   │   │   └── message_provider.dart
│   │   ├── services/                    # API接口
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── storage_service.dart
│   │   ├── theme/                       # 主题配置
│   │   │   └── app_theme.dart
│   │   ├── utils/                       # 工具类
│   │   │   └── error_handler.dart
│   │   ├── widgets/                     # 自定义组件
│   │   │   └── location_picker_page.dart
│   │   ├── main.dart                    # 应用入口
│   │   └── routes.dart                  # 路由配置
│   ├── android/                         # Android平台代码
│   ├── ios/                             # iOS平台代码
│   ├── web/                             # Web平台代码
│   ├── windows/                         # Windows平台代码
│   ├── linux/                           # Linux平台代码
│   ├── macos/                           # macOS平台代码
│   ├── assets/                          # 资源文件
│   │   └── fonts/                      # 字体文件
│   └── pubspec.yaml                     # Flutter配置
├── hitutor-backend/                      # 后端项目
│   ├── src/main/java/com/hitutor/        # Java源代码
│   │   ├── config/                      # 配置类
│   │   │   ├── CustomAccessDeniedHandler.java
│   │   │   ├── GlobalExceptionHandler.java
│   │   │   ├── JacksonConfig.java
│   │   │   ├── JwtAuthenticationFilter.java
│   │   │   ├── MyMetaObjectHandler.java
│   │   │   ├── SecurityConfig.java
│   │   │   ├── WebConfig.java
│   │   │   └── WebSocketConfig.java
│   │   ├── controller/                  # 控制器
│   │   │   ├── AdminController.java
│   │   │   ├── AppointmentController.java
│   │   │   ├── AuthController.java
│   │   │   ├── BlacklistController.java
│   │   │   ├── ComplaintController.java
│   │   │   ├── FavoriteController.java
│   │   │   ├── MessageController.java
│   │   │   ├── NotificationController.java
│   │   │   ├── PointController.java
│   │   │   ├── RequestApplicationController.java
│   │   │   ├── ReviewController.java
│   │   │   ├── StudentRequestController.java
│   │   │   ├── SubjectController.java
│   │   │   ├── TutorCertificationController.java
│   │   │   ├── TutorProfileController.java
│   │   │   ├── TutorResumeController.java
│   │   │   ├── UserController.java
│   │   │   └── VerificationController.java
│   │   ├── document/                    # 文档
│   │   │   └── ChatMessage.java
│   │   ├── dto/                         # 数据传输对象
│   │   │   ├── AppointmentDTO.java
│   │   │   ├── ComplaintDTO.java
│   │   │   ├── RequestApplicationDTO.java
│   │   │   ├── ReviewDTO.java
│   │   │   ├── StudentRequestDTO.java
│   │   │   ├── TutorProfileDTO.java
│   │   │   └── UserDTO.java
│   │   ├── entity/                      # 实体类
│   │   │   ├── Appointment.java
│   │   │   ├── Blacklist.java
│   │   │   ├── Complaint.java
│   │   │   ├── Conversation.java
│   │   │   ├── Favorite.java
│   │   │   ├── Notification.java
│   │   │   ├── PointRecord.java
│   │   │   ├── RequestApplication.java
│   │   │   ├── Review.java
│   │   │   ├── StudentRequest.java
│   │   │   ├── TutorCertification.java
│   │   │   ├── TutorProfile.java
│   │   │   ├── TutorResume.java
│   │   │   ├── TutorSubject.java
│   │   │   └── User.java
│   │   ├── mapper/                      # 数据访问
│   │   │   ├── AppointmentMapper.java
│   │   │   ├── ComplaintMapper.java
│   │   │   ├── ConversationMapper.java
│   │   │   ├── FavoriteMapper.java
│   │   │   ├── NotificationMapper.java
│   │   │   ├── PointRecordMapper.java
│   │   │   ├── RequestApplicationMapper.java
│   │   │   ├── ReviewMapper.java
│   │   │   ├── StudentRequestMapper.java
│   │   │   ├── TutorCertificationMapper.java
│   │   │   ├── TutorProfileMapper.java
│   │   │   ├── TutorResumeMapper.java
│   │   │   ├── UserMapper.java
│   │   │   └── SubjectMapper.java
│   │   └── HiTutorApplication.java      # 应用入口
│   ├── src/main/resources/               # 资源文件
│   │   ├── application.yml               # 应用配置
│   │   └── application.properties        # 应用配置
│   └── pom.xml                         # Maven配置
├── assest/                             # 项目资源
│   ├── certification_submitted_successfully.jpg
│   ├── home_page.jpg
│   ├── logo.svg
│   ├── map_page.jpg
│   ├── points_page.jpg
│   ├── profile_page.jpg
│   ├── publish_student_request_page.jpg
│   ├── publish_tutor_service_page.jpg
│   ├── splash_page.jpg
│   ├── student_request_detail_page.jpg
│   ├── tutor_certification_certificate.jpg
│   ├── tutor_certification_form_page.jpg
│   └── tutor_certified_page.jpg
├── data.sql                            # 数据库初始化脚本
├── API_RESPONSE_FORMAT.md                # API响应格式文档
└── README.md                           # 项目说明文档
```

## 数据库设计

### 主要数据表
- **用户表 (users)** - 存储用户基本信息
- **家教信息表 (tutor_profiles)** - 存储家教老师信息
- **学生需求表 (student_requests)** - 存储学生需求信息
- **预约表 (appointments)** - 存储预约信息
- **评价表 (reviews)** - 存储评价信息
- **收藏表 (favorites)** - 存储收藏信息
- **黑名单表 (blacklists)** - 存储黑名单信息
- **投诉表 (complaints)** - 存储投诉信息
- **积分记录表 (point_records)** - 存储积分记录
- **通知表 (notifications)** - 存储通知信息
- **消息表 (messages)** - 存储聊天消息
- **会话表 (conversations)** - 存储聊天会话
- **科目表 (subjects)** - 存储科目信息

## 开发指南

### 移动客户端开发

#### 添加新页面
1. 在 `client/lib/pages/` 对应目录下创建新的页面文件
2. 在 `client/lib/routes.dart` 中添加路由配置
3. 在需要的地方使用 `Navigator.pushNamed` 导航到新页面

#### 添加新的API接口
1. 在 `client/lib/services/api_service.dart` 中添加API方法
2. 在对应的Service类中封装业务逻辑
3. 在Provider中添加状态管理方法

#### 状态管理
项目使用Provider进行状态管理，主要Provider包括：
- `AuthProvider` - 用户认证状态管理
- `TutorProvider` - 家教信息状态管理
- `MessageProvider` - 消息状态管理

### 后端开发

#### 添加新的API接口
1. 在 `hitutor-backend/src/main/java/com/hitutor/controller/` 中创建Controller
2. 在Service层实现业务逻辑
3. 在Mapper层实现数据访问
4. 在Entity层定义数据模型

#### 数据库操作
使用MyBatis Plus进行数据库操作，支持：
- 基础CRUD操作
- 条件查询
- 分页查询
- 关联查询

## 常见问题

### 1. 如何修改API地址？
编辑 `client/lib/services/api_service.dart` 文件，修改 `baseUrl` 常量的值。

### 2. 如何配置数据库？
编辑 `hitutor-backend/src/main/resources/application.yml` 文件，修改数据库连接信息。

### 3. 如何运行项目？
- 后端：`cd hitutor-backend && mvn spring-boot:run`
- 前端：`cd client && flutter run`

### 4. 如何构建生产版本？
- 后端：`cd hitutor-backend && mvn clean package`
- 前端：`cd client && flutter build apk` 或 `flutter build ios`

## 版本历史

### v1.0.0 (2026-01-26)
- HiTutor家教信息对接共享平台正式上线
- 完整的用户认证系统
- 家教信息发布和管理功能
- 学生需求发布和管理功能
- 在线沟通和聊天功能
- 预约和报名管理功能
- 评价和收藏系统
- 黑名单和投诉功能
- 积分系统
- 移动端iOS和Android支持

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- **GitHub 仓库**: [https://github.com/YangShengzhou03/HiTutor](https://github.com/YangShengzhou03/HiTutor)
- **问题反馈**: [GitHub Issues](https://github.com/YangShengzhou03/HiTutor/issues)
- **邮箱**: dev@hitutor.com
- **项目主页**: [https://github.com/YangShengzhou03/HiTutor](https://github.com/YangShengzhou03/HiTutor)

## 项目统计

![GitHub Release](https://img.shields.io/github/v/release/YangShengzhou03/HiTutor?style=flat-square)
![GitHub Last Commit](https://img.shields.io/github/last-commit/YangShengzhou03/HiTutor?style=flat-square)
![GitHub Contributors](https://img.shields.io/github/contributors/YangShengzhou03/HiTutor?style=flat-square)
![GitHub Repo Size](https://img.shields.io/github/repo-size/YangShengzhou03/HiTutor?style=flat-square)

---

感谢使用 HiTutor好会帮家教信息对接共享平台！

<div align="center">

如果这个项目对您有帮助，请给个 Star 支持一下！

[![Star History Chart](https://api.star-history.com/svg?repos=YangShengzhou03/HiTutor&type=Date)](https://star-history.com/#YangShengzhou03/HiTutor&Date)

</div>
