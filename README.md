# HiTutor好会帮 —— 家教信息对接平台

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/YangShengzhou03/HiTutor?style=for-the-badge&logo=github)](https://github.com/YangShengzhou03/HiTutor/stargazers)&nbsp;[![GitHub forks](https://img.shields.io/github/forks/YangShengzhou03/HiTutor?style=for-the-badge&logo=github)](https://github.com/YangShengzhou03/HiTutor/network/members)&nbsp;[![GitHub issues](https://img.shields.io/github/issues/YangShengzhou03/HiTutor?style=for-the-badge&logo=github)](https://github.com/YangShengzhou03/HiTutor/issues)&nbsp;[![GitHub license](https://img.shields.io/github/license/YangShengzhou03/HiTutor?style=for-the-badge)](https://github.com/YangShengzhou03/HiTutor/blob/main/LICENSE)&nbsp;[![Flutter](https://img.shields.io/badge/Flutter-3.2.6-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)&nbsp;[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.1.0-6DB33F?style=for-the-badge&logo=springboot)](https://spring.io/projects/spring-boot)

<div align="center">
  <img src="https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/logo.svg" alt="HiTutor Logo" width="120" height="120">
  <h3>一个现代化的家教信息对接共享平台，采用前后端分离架构</h3>
  <p>免费、公平、透明的家教信息对接服务，连接学生与专业家教老师</p>
</div>

[快速开始](#快速开始) • [功能特性](#功能特性) • [技术架构](#技术架构) • [API文档](API_RESPONSE_FORMAT.md)

</div>

## 项目简介

HiTutor好会帮是一个纯公益的家教信息对接共享平台，连接学生与专业家教老师。平台仅提供家教信息发布、搜索、对接、沟通等中介信息服务，不提供任何家教教学，不参与任何教学辅导、培训等相关活动。平台提供移动端客户端和后端API接口，通过信息匹配、在线沟通、预约对接、评价反馈等全流程数字化信息服务，提升家教信息对接的透明度和信息质量，降低双方的沟通和匹配成本。

本软件采用前后端分离架构，前端使用Flutter框架开发移动端应用，支持iOS和Android双平台，后端使用Spring Boot框架提供RESTful API接口服务。通过现代化的技术架构和人性化的交互设计，为用户提供便捷、高效、安全的家教信息对接服务。平台的核心价值在于打破信息壁垒，让家教老师和学生家长能够直接对接，减少中间环节，提高匹配效率。

平台的设计理念是简单、高效、安全。简单体现在用户界面简洁明了，操作流程清晰易懂，用户无需复杂的学习成本即可快速上手。高效体现在信息匹配精准，搜索功能强大，用户可以快速找到合适的家教或需求。安全体现在数据传输加密，身份认证严格，用户信息安全有保障。

平台的技术架构采用微服务思想，将系统划分为多个独立的服务模块，每个模块负责特定的功能。这种架构设计使得系统具有良好的可扩展性和可维护性，可以方便地添加新功能或修改现有功能。平台还采用缓存机制，提高系统响应速度，优化用户体验。

平台致力于为家教老师和学生家长提供一个免费、公平、透明的信息对接平台，打破传统家教中介的高收费模式，让更多家庭能够负担得起优质的家教服务。平台建立了完善的信息审核机制，确保信息真实可靠，保障用户权益。

## 功能特性

### 移动客户端功能

**用户认证** - 手机号注册登录、密码登录、短信验证码登录、实名认证、家教教师资质认证

**家教信息** - 发布家教信息、设置授课科目、时薪价格、授课地点、可授课时间段
![发布家教信息](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/publish_tutor_service_page.jpg)

**学生需求** - 发布家教需求、选择辅导科目、设置学生年级、时薪预算、上课地点
![发布学生需求](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/publish_student_request_page.jpg)

**智能搜索** - 按科目筛选、按年级筛选、基于地理位置的附近搜索、按时薪范围筛选、关键词搜索
![地图页面](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/map_page.jpg)

**在线沟通** - 用户间即时聊天、聊天会话管理、消息实时推送、支持文字和图片消息

**预约报名** - 对家教信息/学生需求发起报名、报名状态跟踪、预约时间确认

**预约管理** - 预约信息查看、预约状态管理、预约历史记录、预约取消和完成确认

**评价系统** - 完成对接后评价、1-5星评分、文字评价、评价历史记录

**收藏功能** - 收藏家教信息/学生需求、收藏列表管理、收藏状态实时同步

**黑名单** - 添加用户到黑名单、黑名单列表管理、黑名单用户隔离

**积分系统** - 积分获取和消耗、积分余额查看、积分明细记录
![积分页面](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/points_page.jpg)

**投诉举报** - 用户投诉功能、投诉分类、投诉进度查看

**消息通知** - 系统消息推送、报名申请通知、预约状态变更通知、消息已读/未读管理

**用户主页** - 个人信息展示、已发布信息/需求列表、评价记录、积分信息
![我的页面](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/profile_page.jpg)

## 页面展示

### 首页
**首页** - 展示平台主要功能入口，包括家教信息、学生需求、搜索功能等
![首页](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/home_page.jpg)

### 启动页面
**启动页面** - 应用启动时展示的欢迎页面
![启动页面](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/splash_page.jpg)

### 学生需求详情
**学生需求详情** - 查看学生发布的家教需求详细信息
![学生需求详情](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/student_request_detail_page.jpg)

### 家教认证
**家教认证** - 家教教师资质认证流程，包括填写认证信息、提交材料、审核等步骤
![家教认证表单](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/tutor_certification_form_page.jpg)

**认证状态** - 家教认证通过后显示已认证状态
![家教已认证](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/tutor_certified_page.jpg)

**认证证书** - 家教认证通过后获得的电子版认证证书
![家教认证证书](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/tutor_certification_certificate.jpg)

**认证提交成功** - 提交认证信息后显示的成功提示页面
![认证提交成功](https://gitee.com/Yangshengzhou/hi-tutor/raw/master/assets/certification_submitted_successfully.jpg)

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

### 环境配置说明

#### Java环境配置
Java 17是后端开发的基础环境，Spring Boot 3.1.0框架要求Java 17或更高版本。安装Java 17后，需要配置JAVA_HOME环境变量，并将Java的bin目录添加到PATH环境变量中。可以通过运行`java -version`命令验证Java是否正确安装。

#### Flutter环境配置
Flutter 3.2.6是移动客户端开发的基础框架，支持iOS、Android、Web、Windows、macOS、Linux等多个平台。安装Flutter SDK后，需要配置Flutter的环境变量，并将Flutter的bin目录添加到PATH环境变量中。可以通过运行`flutter doctor`命令检查Flutter环境是否正确配置，该命令会检查Flutter、Dart、Android SDK、Xcode等工具的安装情况。

#### MySQL数据库配置
MySQL 8.0.33是项目使用的数据库管理系统，用于存储用户信息、家教信息、学生需求、预约、评价、收藏、黑名单、积分、投诉、通知、消息等数据。安装MySQL后，需要创建数据库并执行初始化脚本，初始化脚本包含创建表、插入初始数据等操作。

#### Maven环境配置
Maven 3.6+是后端项目的构建工具，用于管理项目依赖、编译项目、打包项目等。安装Maven后，需要配置Maven的环境变量，并将Maven的bin目录添加到PATH环境变量中。可以通过运行`mvn -version`命令验证Maven是否正确安装。

## 安装部署

### 1. 克隆项目
```bash
git clone https://github.com/YangShengzhou03/HiTutor.git
cd HiTutor
```

克隆项目后，项目目录包含两个主要子目录：client目录包含Flutter移动客户端项目，hitutor-backend目录包含Spring Boot后端项目。需要分别进入这两个目录进行配置和部署。

### 2. 数据库配置

#### 配置数据库
```sql
-- 创建数据库
CREATE DATABASE hitutor CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 执行初始化脚本
USE hitutor;
SOURCE data.sql;
```

数据库配置是项目运行的基础，MySQL 8.0.33数据库需要创建hitutor数据库，并设置字符集为utf8mb4，支持存储中文等Unicode字符。初始化脚本data.sql包含创建用户表、家教信息表、学生需求表、预约表、评价表、收藏表、黑名单表、积分表、投诉表、通知表、消息表、科目表等数据库表的SQL语句，以及插入初始数据的SQL语句。

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

application.yml是Spring Boot应用的配置文件，包含数据库连接配置、JWT令牌配置、服务器端口配置等。数据库连接配置包括数据库URL、用户名、密码，需要根据实际情况修改。JWT令牌配置包括密钥和过期时间，密钥用于生成和验证JWT令牌，过期时间设置令牌的有效期，单位为毫秒，86400000毫秒表示24小时。服务器端口配置设置Spring Boot应用监听的端口号，默认为8080。

#### 启动后端服务
```bash
cd hitutor-backend

# 编译项目
mvn clean package

# 运行应用
java -jar target/hitutor-backend-1.0.0.jar
```

编译项目使用Maven的clean package命令，clean命令清理编译输出，package命令编译项目并打包为JAR文件。编译成功后，会在target目录下生成hitutor-backend-1.0.0.jar文件，这是可执行的JAR文件，包含所有依赖和应用程序代码。运行应用使用java -jar命令，指定JAR文件的路径，启动Spring Boot应用。

### 4. 移动客户端部署

#### 安装依赖
```bash
cd client
flutter pub get
```

flutter pub get命令会读取client/pubspec.yaml文件，下载并安装项目依赖的所有Flutter包和Dart包。pubspec.yaml文件列出了项目依赖的所有包，包括provider、http、shared_preferences、amap_flutter_map、geolocator、permission_handler等。依赖安装完成后，会在client/.dart_tool目录下生成依赖包的缓存。

#### 配置API地址
编辑 `client/lib/services/api_service.dart`：
```dart
class ApiService {
  static const String baseUrl = 'http://your-server-ip:8080/api';
  // ...
}
```

API地址配置需要根据实际部署的后端服务器地址进行修改。如果后端服务器部署在本地，可以使用http://localhost:8080/api；如果后端服务器部署在远程服务器，需要将localhost替换为服务器的IP地址或域名。API地址是移动客户端与后端服务器通信的基础，所有API请求都会发送到这个地址。

#### 运行应用
```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome
```

flutter run命令会编译Flutter应用并在指定的设备或模拟器上运行。如果不指定设备，Flutter会自动检测可用的设备并选择一个运行。Android设备需要连接Android手机或启动Android模拟器，iOS设备需要连接iPhone或启动iOS模拟器，Web平台需要在Chrome浏览器中运行。flutter run命令支持热重载功能，修改代码后可以快速看到效果，无需重新编译整个应用。

### 5. 生产环境部署

#### 后端生产部署
生产环境部署需要考虑安全性、性能、可靠性等因素。建议使用Linux服务器，配置防火墙，限制只开放必要的端口。可以使用Nginx作为反向代理，配置HTTPS证书，提高数据传输的安全性。可以使用Supervisor或Systemd管理Spring Boot应用，实现应用的自动重启和日志管理。

#### 前端生产部署
生产环境部署需要将Flutter应用打包为APK文件或IPA文件，发布到应用商店或通过其他方式分发。Android平台可以使用flutter build apk命令打包APK文件，iOS平台可以使用flutter build ios命令打包IPA文件。打包前需要修改应用图标、应用名称、版本号等信息，确保应用符合发布规范。

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
├── assets/                             # 项目资源
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

## 关于作者

### 开发者简介

**杨圣洲**，籍贯吉安县，2022年参加江西省职教高考（三校生），以559分获得全省第一名，考入江西科技师范大学信息管理与信息系统专业。

### 技术背景

大学期间，系统学习 Linux、Docker、K8S 等 DevOps 与运维相关技术，专注于 Windows 桌面工具、自动化解决方案及企业级系统的研发与落地，开发了多款不同场景的项目。

### 代表项目

- **Jobs_helper（海投助手）**：浏览器脚本插件，聚焦 Boss 直聘平台，具备自动化简历投递、AI 智能回复 HR 消息等功能
- **LeafSort（轻羽媒体整理）**：融合深度学习算法与多线程处理能力，可对海量照片与视频进行整理、归类及去重，通过微软应用商店、联想应用商店分发，适配 Windows 系统
- **LeafPan**：基于 Vue 3 + Spring Boot 3 技术栈构建，为企业级文件管理平台
- **LeafBoss**：基于 Spring Boot 3 + Vue3 + Element Plus + MySQL + JavaScript 技术栈构建，专注于卡密全生命周期管理与安全验证服务
- **Lucky_SMS**：教育类开源系统，基于 Vue 3 和 Spring Boot 开发，具备多角色权限控制，适用于毕业设计、商业应用及教育管理场景，后续更新了用户信息脱敏功能
- **HiTutor好会帮**：家教信息对接共享平台，采用 Flutter + Spring Boot 技术栈，为学生和家教老师提供免费、公平、透明的信息对接服务

---

感谢使用 HiTutor好会帮家教信息对接共享平台！

<div align="center">

如果这个项目对您有帮助，请给个 Star 支持一下！

[![Star History Chart](https://api.star-history.com/svg?repos=YangShengzhou03/HiTutor&type=Date)](https://star-history.com/#YangShengzhou03/HiTutor&Date)

</div>
