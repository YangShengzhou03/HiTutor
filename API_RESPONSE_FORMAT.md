# API响应格式文档

## 统一响应格式

所有API接口都遵循统一的响应格式，包含以下字段：

### 基础响应结构

```json
{
  "success": true,
  "message": "操作结果描述",
  "data": {}
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| success | Boolean | 操作是否成功，true表示成功，false表示失败 |
| message | String | 操作结果的描述信息（部分接口可能不包含此字段） |
| data | Any | 返回的数据，成功时包含具体数据，失败时可能为null |

### 响应格式说明

本系统采用统一的响应格式，所有API接口都遵循这个格式，确保前端可以统一处理响应数据。success字段表示操作是否成功，true表示操作成功，false表示操作失败。message字段提供操作结果的描述信息，帮助用户了解操作的结果，部分接口可能不包含此字段。data字段包含返回的具体数据，成功时包含业务数据，失败时可能为null或包含错误信息。

统一的响应格式具有以下优点：第一，前端可以统一处理响应数据，减少重复代码；第二，响应格式清晰明了，易于理解和使用；第三，便于接口调试和错误排查；第四，提高代码可维护性，降低开发成本。

---

## 成功响应示例

### 1. 单个对象数据

```json
{
  "success": true,
  "message": "获取用户信息成功",
  "data": {
    "id": "123",
    "username": "张三",
    "phone": "13800138000",
    "email": "zhangsan@example.com",
    "role": "student",
    "isVerified": true,
    "points": 100
  }
}
```

### 2. 列表数据（不分页）

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "数学",
      "status": "active"
    },
    {
      "id": 2,
      "name": "英语",
      "status": "active"
    }
  ]
}
```

### 3. 分页数据

```json
{
  "success": true,
  "message": "获取家教列表成功",
  "data": {
    "content": [
      {
        "id": 1,
        "userId": "123",
        "subjectName": "数学",
        "hourlyRate": "100-150",
        "status": "available"
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 50
  }
}
```

### 4. 登录响应

```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "123",
      "username": "张三",
      "phone": "13800138000",
      "email": "zhangsan@example.com",
      "role": "student"
    },
    "isFirstLogin": false
  }
}
```

### 5. 布尔值数据

```json
{
  "success": true,
  "message": "查询成功",
  "data": true
}
```

### 6. 整数数据

```json
{
  "success": true,
  "message": "获取未读数量成功",
  "data": 5
}
```

---

## 失败响应示例

### 1. 未授权（401）

```json
{
  "success": false,
  "message": "未授权",
  "data": null
}
```

### 2. 禁止访问（403）

```json
{
  "success": false,
  "message": "禁止访问",
  "data": null
}
```

### 3. 资源不存在（404）

```json
{
  "success": false,
  "message": "用户不存在",
  "data": null
}
```

### 4. 业务错误（400）

```json
{
  "success": false,
  "message": "邮箱或密码错误",
  "data": null
}
```

### 5. 服务器错误（500）

```json
{
  "success": false,
  "message": "操作失败",
  "data": null
}
```

---

## HTTP状态码

| 状态码 | 说明 | 使用场景 |
|--------|------|----------|
| 200 | OK | 请求成功 |
| 201 | Created | 资源创建成功 |
| 400 | Bad Request | 请求参数错误 |
| 401 | Unauthorized | 未授权或Token无效 |
| 403 | Forbidden | 权限不足 |
| 404 | Not Found | 资源不存在 |
| 500 | Internal Server Error | 服务器内部错误 |

### HTTP状态码说明

HTTP状态码是HTTP协议中用于表示HTTP请求处理结果的三位数字代码，本系统使用标准的HTTP状态码来表示API请求的处理结果。

200 OK表示请求成功，服务器成功处理了请求并返回了响应数据。这是最常见的状态码，表示操作成功完成。

201 Created表示资源创建成功，服务器成功创建了新资源并返回了响应数据。这个状态码通常用于POST请求，表示资源创建成功。

400 Bad Request表示请求参数错误，服务器无法理解客户端发送的请求。这个状态码通常表示客户端发送的请求参数有误，例如缺少必填参数、参数格式错误等。

401 Unauthorized表示未授权或Token无效，客户端没有提供有效的身份认证信息。这个状态码通常表示用户未登录或登录令牌已过期，需要重新登录获取新的令牌。

403 Forbidden表示权限不足，客户端虽然提供了有效的身份认证信息，但没有权限访问请求的资源。这个状态码通常表示用户没有权限执行某个操作，例如普通用户尝试访问管理员功能。

404 Not Found表示资源不存在，服务器找不到请求的资源。这个状态码通常表示请求的资源ID不存在或已被删除。

500 Internal Server Error表示服务器内部错误，服务器在处理请求时发生了错误。这个状态码通常表示服务器端出现了异常，需要开发人员排查问题。

---

## 各模块响应格式

### 用户模块 (User)

#### 获取当前用户信息
```json
{
  "success": true,
  "message": "获取用户信息成功",
  "data": {
    "id": "123",
    "username": "张三",
    "avatar": "https://example.com/avatar.jpg",
    "phone": "13800138000",
    "email": "zhangsan@example.com",
    "gender": "男",
    "birthDate": "1990-01-01",
    "education": "本科",
    "school": "北京大学",
    "major": "计算机科学",
    "teachingExperience": 5,
    "isVerified": true,
    "role": "tutor",
    "createdAt": "2024-01-01 10:00:00",
    "points": 100
  }
}
```

#### 获取用户列表（分页）
```json
{
  "success": true,
  "message": "获取用户列表成功",
  "data": {
    "content": [
      {
        "id": "123",
        "username": "张三",
        "phone": "13800138000",
        "email": "zhangsan@example.com",
        "role": "student",
        "isVerified": true
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 50
  }
}
```

#### 获取家教列表（分页）
```json
{
  "success": true,
  "message": "获取家教列表成功",
  "data": {
    "content": [
      {
        "id": "123",
        "username": "张三",
        "phone": "13800138000",
        "email": "zhangsan@example.com",
        "role": "tutor",
        "isVerified": true
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 50
  }
}
```

### 认证模块 (Auth)

#### 登录成功
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "123",
      "name": "张三",
      "phone": "13800138000",
      "email": "zhangsan@example.com",
      "role": "student"
    },
    "isFirstLogin": false
  }
}
```

#### 登录失败
```json
{
  "success": false,
  "message": "邮箱或密码错误",
  "data": null
}
```

#### 登录失败（账号被禁用）
```json
{
  "success": false,
  "message": "账号已被禁用，请联系管理员",
  "data": null
}
```

### 家教信息模块 (TutorProfile)

#### 获取家教列表（分页）
```json
{
  "success": true,
  "message": "获取家教列表成功",
  "data": {
    "content": [
      {
        "id": 1,
        "userId": "123",
        "userName": "张三",
        "userAvatar": "https://example.com/avatar.jpg",
        "userVerified": true,
        "subjectId": 1,
        "subjectName": "数学",
        "hourlyRate": "100-150",
        "address": "北京市朝阳区",
        "latitude": "39.9042",
        "longitude": "116.4074",
        "description": "本人有5年教学经验...",
        "availableTime": "周末",
        "targetGradeLevels": "小学,初中",
        "status": "available",
        "rating": 4.8,
        "reviewCount": 20,
        "createdAt": "2024-01-01 10:00:00"
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 50
  }
}
```

#### 获取附近家教
```json
{
  "success": true,
  "message": "获取附近家教成功",
  "data": [
    {
      "id": 1,
      "userId": "123",
      "userName": "张三",
      "userAvatar": "https://example.com/avatar.jpg",
      "userVerified": true,
      "subjectId": 1,
      "subjectName": "数学",
      "hourlyRate": "100-150",
      "address": "北京市朝阳区",
      "latitude": "39.9042",
      "longitude": "116.4074",
      "description": "本人有5年教学经验...",
      "availableTime": "周末",
      "targetGradeLevels": "小学,初中",
      "status": "available",
      "rating": 4.8,
      "reviewCount": 20,
      "createdAt": "2024-01-01 10:00:00"
    }
  ]
}
```

### 学生需求模块 (StudentRequest)

#### 获取学生需求列表（分页）
```json
{
  "success": true,
  "message": "获取学生需求列表成功",
  "data": {
    "content": [
      {
        "id": 1,
        "userId": "456",
        "userName": "李四",
        "userAvatar": "https://example.com/avatar.jpg",
        "childName": "小明",
        "childGrade": "小学三年级",
        "subjectId": 1,
        "subjectName": "数学",
        "address": "北京市朝阳区",
        "latitude": "39.9042",
        "longitude": "116.4074",
        "hourlyRateMin": "80",
        "hourlyRateMax": "120",
        "requirements": "每周两次，周末",
        "availableTime": "周末",
        "status": "pending",
        "createdAt": "2024-01-01 10:00:00"
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 30
  }
}
```

#### 获取附近学生需求
```json
{
  "success": true,
  "message": "获取附近学生需求成功",
  "data": [
    {
      "id": 1,
      "userId": "456",
      "userName": "李四",
      "userAvatar": "https://example.com/avatar.jpg",
      "childName": "小明",
      "childGrade": "小学三年级",
      "subjectId": 1,
      "subjectName": "数学",
      "address": "北京市朝阳区",
      "latitude": "39.9042",
      "longitude": "116.4074",
      "hourlyRateMin": "80",
      "hourlyRateMax": "120",
      "requirements": "每周两次，周末",
      "availableTime": "周末",
      "status": "pending",
      "createdAt": "2024-01-01 10:00:00"
    }
  ]
}
```

### 预约模块 (Appointment)

#### 获取预约列表
```json
{
  "success": true,
  "message": "获取预约列表成功",
  "data": [
    {
      "id": 1,
      "tutorId": "123",
      "tutorName": "张三",
      "tutorAvatar": "https://example.com/avatar.jpg",
      "tutorPhone": "13800138000",
      "tutorVerified": true,
      "studentId": "456",
      "studentName": "李四",
      "studentAvatar": "https://example.com/avatar.jpg",
      "studentPhone": "13900139000",
      "subjectId": 1,
      "subjectName": "数学",
      "appointmentTime": "2024-01-15 14:00:00",
      "duration": 2,
      "address": "北京市朝阳区",
      "hourlyRate": "100",
      "totalAmount": "200",
      "status": "confirmed",
      "notes": "第一次上课",
      "createdAt": "2024-01-10 10:00:00"
    }
  ]
}
```

### 评价模块 (Review)

#### 获取评价列表
```json
{
  "success": true,
  "message": "获取评价成功",
  "data": [
    {
      "id": 1,
      "appointmentId": 1,
      "reviewerId": "456",
      "reviewerName": "李四",
      "reviewerAvatar": "https://example.com/avatar.jpg",
      "reviewedId": "123",
      "rating": 5,
      "comment": "老师非常耐心，孩子很喜欢",
      "createdAt": "2024-01-16 10:00:00"
    }
  ]
}
```

#### 创建评价
```json
{
  "success": true,
  "data": {
    "id": 1,
    "appointmentId": 1,
    "reviewerId": "456",
    "reviewerName": "李四",
    "reviewerAvatar": "https://example.com/avatar.jpg",
    "reviewedId": "123",
    "rating": 5,
    "comment": "老师非常耐心，孩子很喜欢",
    "createdAt": "2024-01-16 10:00:00"
  },
  "message": "评价成功"
}
```

### 收藏模块 (Favorite)

#### 获取收藏列表
```json
{
  "success": true,
  "message": "获取收藏列表成功",
  "data": [
    {
      "id": 1,
      "userId": "456",
      "targetId": 1,
      "targetType": "tutor_profile",
      "createTime": "2024-01-10 10:00:00",
      "target": {
        "username": "张三",
        "userId": "123",
        "subjectName": "数学",
        "hourlyRate": "100-150"
      }
    }
  ]
}
```

#### 检查是否收藏
```json
{
  "success": true,
  "message": "查询成功",
  "data": true
}
```

### 通知模块 (Notification)

#### 获取通知列表
```json
{
  "success": true,
  "message": "获取通知列表成功",
  "data": [
    {
      "id": 1,
      "userId": "456",
      "type": "system",
      "title": "系统通知",
      "content": "您的预约已确认",
      "isRead": 0,
      "createTime": "2024-01-15 10:00:00"
    }
  ]
}
```

#### 获取未读数量
```json
{
  "success": true,
  "message": "获取未读数量成功",
  "data": 5
}
```

### 科目模块 (Subject)

#### 获取科目列表
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "数学",
      "status": "active"
    },
    {
      "id": 2,
      "name": "英语",
      "status": "active"
    }
  ]
}
```

#### 获取活跃科目列表
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "数学",
      "status": "active"
    },
    {
      "id": 2,
      "name": "英语",
      "status": "active"
    }
  ]
}
```

#### 获取单个科目
```json
{
  "success": true,
  "message": "获取科目成功",
  "data": {
    "id": 1,
    "name": "数学",
    "status": "active"
  }
}
```

#### 创建科目
```json
{
  "success": true,
  "message": "创建科目成功",
  "data": {
    "id": 1,
    "name": "数学",
    "status": "active"
  }
}
```

#### 更新科目
```json
{
  "success": true,
  "message": "更新科目成功",
  "data": {
    "id": 1,
    "name": "数学",
    "icon": "calculate",
    "status": "active",
    "sortOrder": 1
  }
}
```

#### 删除科目
```json
{
  "success": true,
  "message": "删除科目成功"
}
```

### 积分模块 (Point)

#### 获取积分记录
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "userId": "456",
      "points": 5,
      "type": "login",
      "description": "每日登录奖励",
      "createTime": "2024-01-15 10:00:00"
    }
  ]
}
```

#### 获取总积分
```json
{
  "success": true,
  "data": {
    "totalPoints": 100
  }
}
```

#### 管理员添加积分
```json
{
  "success": true,
  "message": "积分操作成功"
}
```

#### 管理员扣除积分
```json
{
  "success": true,
  "message": "积分扣除成功"
}
```

### 消息模块 (Message)

#### 获取会话列表
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user1Id": "123",
      "user2Id": "456",
      "lastMessageTime": "2024-01-15 10:00:00",
      "unreadCount": 2,
      "user": {
        "id": "456",
        "name": "李四",
        "avatar": "https://example.com/avatar.jpg"
      }
    }
  ]
}
```

#### 获取消息列表（分页）
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "msg123",
        "conversationId": "1",
        "senderId": "123",
        "receiverId": "456",
        "content": "你好",
        "messageType": "text",
        "isRead": false,
        "createTime": "2024-01-15 10:00:00"
      }
    ],
    "totalElements": 50,
    "totalPages": 3,
    "currentPage": 0,
    "size": 20
  }
}
```

#### 创建会话
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user1Id": "123",
    "user2Id": "456",
    "lastMessageTime": "2024-01-15 10:00:00"
  },
  "message": "会话创建成功"
}
```

#### 发送消息
```json
{
  "success": true,
  "data": {
    "id": "msg123",
    "conversationId": "1",
    "senderId": "123",
    "receiverId": "456",
    "content": "你好",
    "messageType": "text",
    "isRead": false,
    "createTime": "2024-01-15 10:00:00"
  },
  "message": "消息发送成功"
}
```

#### 标记消息为已读
```json
{
  "success": true,
  "message": "消息已标记为已读"
}
```

#### 删除会话
```json
{
  "success": true,
  "message": "会话删除成功"
}
```

#### 删除消息
```json
{
  "success": true,
  "message": "消息删除成功"
}
```

### 报名模块 (RequestApplication)

#### 获取报名列表（分页）
```json
{
  "success": true,
  "message": "获取报名列表成功",
  "data": {
    "content": [
      {
        "id": 1,
        "tutorId": "123",
        "tutorName": "张三",
        "tutorAvatar": "https://example.com/avatar.jpg",
        "studentRequestId": 1,
        "studentRequestSubjectName": "数学",
        "studentRequestGrade": "小学三年级",
        "status": "pending",
        "message": "我有5年教学经验，擅长小学数学教学",
        "createTime": "2024-01-10 10:00:00"
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 30
  }
}
```

#### 创建报名申请
```json
{
  "success": true,
  "message": "报名申请提交成功",
  "data": {
    "id": 1,
    "tutorId": "123",
    "tutorName": "张三",
    "studentRequestId": 1,
    "status": "pending",
    "message": "我有5年教学经验，擅长小学数学教学",
    "createTime": "2024-01-10 10:00:00"
  }
}
```

#### 接受报名申请
```json
{
  "success": true,
  "message": "已接受报名申请",
  "data": {
    "id": 1,
    "status": "accepted"
  }
}
```

#### 拒绝报名申请
```json
{
  "success": true,
  "message": "已拒绝报名申请",
  "data": {
    "id": 1,
    "status": "rejected"
  }
}
```

### 黑名单模块 (Blacklist)

#### 获取黑名单列表
```json
{
  "success": true,
  "message": "获取黑名单列表成功",
  "data": [
    {
      "id": 1,
      "userId": "123",
      "blockedUserId": "456",
      "blockedUserName": "李四",
      "blockedUserAvatar": "https://example.com/avatar.jpg",
      "createTime": "2024-01-10 10:00:00"
    }
  ]
}
```

#### 添加到黑名单
```json
{
  "success": true,
  "message": "已添加到黑名单",
  "data": {
    "id": 1,
    "userId": "123",
    "blockedUserId": "456",
    "createTime": "2024-01-10 10:00:00"
  }
}
```

#### 从黑名单移除
```json
{
  "success": true,
  "message": "已从黑名单移除"
}
```

#### 检查是否在黑名单
```json
{
  "success": true,
  "message": "查询成功",
  "data": true
}
```

### 投诉模块 (Complaint)

#### 获取投诉列表
```json
{
  "success": true,
  "message": "获取投诉列表成功",
  "data": [
    {
      "id": 1,
      "userId": "123",
      "userName": "张三",
      "complainedUserId": "456",
      "complainedUserName": "李四",
      "type": "虚假信息",
      "content": "该用户发布的信息与实际情况不符",
      "status": "pending",
      "createTime": "2024-01-10 10:00:00"
    }
  ]
}
```

#### 创建投诉
```json
{
  "success": true,
  "message": "投诉提交成功",
  "data": {
    "id": 1,
    "userId": "123",
    "complainedUserId": "456",
    "type": "虚假信息",
    "content": "该用户发布的信息与实际情况不符",
    "status": "pending",
    "createTime": "2024-01-10 10:00:00"
  }
}
```

### 家教认证模块 (TutorCertification)

#### 获取家教认证信息
```json
{
  "success": true,
  "message": "获取家教认证信息成功",
  "data": {
    "id": 1,
    "userId": "123",
    "userName": "张三",
    "education": "本科",
    "school": "北京大学",
    "major": "计算机科学",
    "teachingExperience": 5,
    "certificateUrl": "https://example.com/certificate.jpg",
    "status": "approved",
    "createTime": "2024-01-10 10:00:00"
  }
}
```

#### 提交家教认证
```json
{
  "success": true,
  "message": "家教认证提交成功，请等待审核",
  "data": {
    "id": 1,
    "userId": "123",
    "status": "pending",
    "createTime": "2024-01-10 10:00:00"
  }
}
```

#### 审核家教认证
```json
{
  "success": true,
  "message": "家教认证审核成功",
  "data": {
    "id": 1,
    "status": "approved"
  }
}
```

---

## 注意事项

1. 所有响应都包含 `success` 字段
2. 成功时 `success` 为 `true`，失败时为 `false`
3. `message` 字段在某些接口中可能不存在
4. `data` 字段在失败时可能为 `null`
5. 分页数据的 `data` 是一个对象，包含 `content`、`page`、`size`、`totalElements` 字段
6. 列表数据（不分页）的 `data` 直接是数组
7. 日期时间格式统一为 `yyyy-MM-dd HH:mm:ss`
8. 金额字段使用字符串类型，避免精度问题
9. 布尔值使用 `true`/`false`，而不是 `0`/`1`
10. ID字段根据实体类型可能为字符串或长整型
11. Token需要在请求头中携带：`Authorization: Bearer {token}`
12. 不同接口的响应字段顺序可能不同

---

## 错误处理

### 常见错误消息

| 错误消息 | 说明 |
|----------|------|
| 未授权 | Token无效或过期 |
| 禁止访问 | 权限不足 |
| 用户不存在 | 指定的用户ID不存在 |
| 邮箱或密码错误 | 登录凭证错误 |
| 账号已被禁用，请联系管理员 | 用户状态异常 |
| 账号已被禁用，无法发布学生需求 | 用户状态异常 |
| 家教信息不存在 | 指定的家教信息ID不存在 |
| 学生需求不存在 | 指定的学生需求ID不存在 |
| 预约不存在 | 指定的预约ID不存在 |
| 评价不存在 | 指定的评价ID不存在 |
| 通知不存在 | 指定的通知ID不存在 |
| 科目不存在 | 指定的科目ID不存在 |
| 您已经收藏过该内容 | 重复收藏 |
| 目标ID格式错误 | ID参数格式不正确 |
| 通知标题不能为空 | 参数验证失败 |
| 通知内容不能为空 | 参数验证失败 |
| 用户ID不能为空 | 参数验证失败 |
| 积分数量不能为空 | 参数验证失败 |
| 积分类型不能为空 | 参数验证失败 |
| 积分说明不能为空 | 参数验证失败 |
| 创建学生需求失败 | 业务逻辑错误 |
| 系统错误，请稍后重试 | 服务器内部错误 |

---

## 数据类型说明

| 字段类型 | Java类型 | JSON类型 | 示例 |
|----------|-----------|-----------|------|
| ID | String / Long | String / Number | "123" / 123 |
| 姓名 | String | String | "张三" |
| 电话 | String | String | "13800138000" |
| 邮箱 | String | String | "zhangsan@example.com" |
| 金额 | String | String | "100" / "100-150" |
| 日期时间 | LocalDateTime | String | "2024-01-15 10:00:00" |
| 布尔值 | Boolean | Boolean | true / false |
| 整数 | Integer | Number | 100 |
| 列表 | List<T> | Array | [...] |
| 对象 | Object | Object | {...} |
