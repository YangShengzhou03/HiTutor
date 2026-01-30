<template>
  <div class="admin-profile">
    <el-card class="profile-card">
      <template #header>
        <div class="card-header">
          <span>个人资料</span>
          <el-button type="primary" @click="editProfile">
            <el-icon>
              <Edit />
            </el-icon>
            修改资料
          </el-button>
        </div>
      </template>

      <div class="profile-content">
        <!-- 用户信息展示 -->
        <div class="user-info-display">
          <div class="avatar-section">
            <el-avatar :size="100" :src="userInfo.avatar" class="user-avatar">
              {{ userInfo.nickname ? userInfo.nickname.charAt(0) : 'U' }}
            </el-avatar>
          </div>

          <div class="info-section">
            <h2 class="user-name">{{ userInfo.nickname ? userInfo.nickname : '未设置昵称' }}</h2>
            <p class="user-email">{{ userInfo.email || '未设置邮箱' }}</p>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">注册时间：</span>
                <span class="info-value">{{ userInfo.createTime ? formatDate(userInfo.createTime) : '未知' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">账户状态：</span>
                <el-tag type="success">正常</el-tag>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 修改资料对话框 -->
    <el-dialog v-model="profileDialogVisible" title="修改资料" width="500px">
      <el-form :model="profileForm" :rules="profileRules" ref="profileFormRef" label-width="80px">
        <el-form-item label="头像" prop="avatar">
          <div class="avatar-upload">
            <el-avatar :size="80" :src="profileForm.avatar" class="preview-avatar">
              {{ profileForm.nickname ? profileForm.nickname.charAt(0) : 'U' }}
            </el-avatar>
            <el-button type="primary" @click="changeAvatar" style="margin-left: 16px;">
              <el-icon>
                <Camera />
              </el-icon>
              更换头像
            </el-button>
            <input ref="avatarInput" type="file" accept="image/*" style="display: none" @change="handleAvatarChange" />
          </div>
        </el-form-item>

        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="profileForm.nickname" placeholder="请输入昵称" maxlength="6" show-word-limit />
        </el-form-item>

        <el-form-item label="邮箱" prop="email">
          <el-input v-model="profileForm.email" placeholder="请输入邮箱" type="email" />
        </el-form-item>

        <el-form-item label="密码" prop="oldPassword">
          <el-input v-model="profileForm.oldPassword" type="password" placeholder="请输入原密码" show-password />
        </el-form-item>

        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="profileForm.newPassword" type="password" placeholder="请输入新密码（留空则不修改）" show-password />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="profileDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveProfile" :loading="saving">
            保存
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Camera, Edit } from '@element-plus/icons-vue'
import api from '../../services/api'
import * as utils from '../../utils/utils.js'

const profileFormRef = ref()
const avatarInput = ref()

const profileDialogVisible = ref(false)
const saving = ref(false)

const userInfo = ref({
  id: '',
  nickname: '',
  email: '',
  avatar: '',
  createTime: ''
})

const profileForm = reactive({
  avatar: '',
  nickname: '',
  email: '',
  oldPassword: '',
  newPassword: ''
})

const profileRules = {
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 6, message: '昵称长度在 2 到 6 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  newPassword: [
    { min: 6, message: '密码长度至少6位', trigger: 'blur' }
  ]
}

const formatDate = (dateString) => {
  if (!dateString) return '未知'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return '未知'
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

const loadUserInfo = async () => {
  try {
    const response = await api.user.getCurrentUser()

    if (response && response.success && response.data) {
      const userData = response.data
      userInfo.value = {
        id: userData.id || '',
        nickname: userData.name || userData.username || '',
        email: userData.email || '',
        avatar: userData.avatar || '',
        createTime: userData.createTime || ''
      }

    } else {
      ElMessage.error(response?.message || '获取用户信息失败')
    }
  } catch (error) {
    console.error('加载用户信息失败:', error)
    ElMessage.error('加载用户信息失败，请检查网络连接')
  }
}

const editProfile = () => {
  Object.assign(profileForm, userInfo.value)
  profileForm.oldPassword = ''
  profileForm.newPassword = ''
  profileDialogVisible.value = true
}

// 保存个人资料
const saveProfile = async () => {
  if (!profileFormRef.value) return

  try {
    await profileFormRef.value.validate()
    saving.value = true

    const submitData = {
      username: profileForm.nickname,
      email: profileForm.email
    }

    if (profileForm.avatar) {
      submitData.avatar = profileForm.avatar
    }

    const response = await api.user.updateUser(userInfo.value.id, submitData)

    if (response && response.success) {
      userInfo.value = { ...userInfo.value, ...profileForm }

      if (profileForm.oldPassword && profileForm.newPassword) {
        const passwordResponse = await api.user.changePassword({
          oldPassword: profileForm.oldPassword,
          newPassword: profileForm.newPassword
        })

        if (!passwordResponse.success) {
          ElMessage.warning('个人资料保存成功，但密码修改失败：' + (passwordResponse.message || ''))
        }
      }

      profileDialogVisible.value = false
      ElMessage.success('个人资料保存成功')
    } else {
      ElMessage.error(response?.message || '保存失败，请重试')
    }
  } catch (error) {
    if (error.errors) {
      ElMessage.warning('请检查表单填写是否正确')
    } else {
      console.error('保存失败:', error)
      ElMessage.error('保存失败，请检查网络连接')
    }
  } finally {
    saving.value = false
  }
}

// 更换头像
const changeAvatar = () => {
  avatarInput.value?.click()
}

// 处理头像更改
const handleAvatarChange = (event) => {
  const file = event.target.files[0]
  if (!file) return

  // 检查文件类型
  if (!file.type.startsWith('image/')) {
    ElMessage.warning('请选择图片文件')
    return
  }

  // 检查文件大小（限制为2MB）
  if (file.size > 2 * 1024 * 1024) {
    ElMessage.warning('图片大小不能超过2MB')
    return
  }

  // 创建预览URL
  const reader = new FileReader()
  reader.onload = (e) => {
    profileForm.avatar = e.target.result
    ElMessage.success('头像更换成功')
  }
  reader.readAsDataURL(file)

  // 重置文件输入
  event.target.value = ''
}

onMounted(() => {
  if (utils.isLoggedIn()) {
    loadUserInfo()
  }
})
</script>

<style scoped>
.admin-profile {
  background-color: transparent;
  padding: 24px;
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

.profile-card {
  width: 100%;
  max-width: 900px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
  overflow: hidden;
}

.profile-card :deep(.el-card__header) {
  background-color: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  padding: 20px 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  font-size: 18px;
  color: #1f2937;
}

.card-header .el-button {
  background-color: #3b82f6;
  border-color: #3b82f6;
  color: white;
  font-weight: 500;
}

.card-header .el-button:hover {
  background-color: #2563eb;
  border-color: #2563eb;
}

.profile-card :deep(.el-card__body) {
  padding: 24px;
  background: white;
}

.profile-content {
  width: 100%;
}

.user-info-display {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  padding: 20px 0;
}

.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.user-avatar {
  border: 3px solid #f1f5f9;
  background-color: #3b82f6;
  color: white;
  font-size: 24px;
  font-weight: 600;
}

.info-section {
  flex: 1;
}

.user-name {
  margin: 0 0 4px 0;
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
}

.user-email {
  margin: 0 0 16px 0;
  color: #6b7280;
  font-size: 14px;
  font-weight: 400;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  margin-top: 20px;
}

.info-item {
  display: flex;
  align-items: center;
  padding: 16px;
  background: #f8fafc;
  border-radius: 6px;
}

.info-label {
  font-weight: 600;
  color: #4b5563;
  min-width: 90px;
  font-size: 14px;
}

.info-value {
  color: #1f2937;
  font-weight: 500;
  font-size: 14px;
}

.avatar-upload {
  display: flex;
  align-items: center;
  gap: 16px;
}

.preview-avatar {
  border: 2px solid #e5e7eb;
  background-color: #3b82f6;
  color: white;
  font-weight: 600;
}

.avatar-upload .el-button {
  background-color: #3b82f6;
  border-color: #3b82f6;
  color: white;
  font-weight: 500;
}

.avatar-upload .el-button:hover {
  background-color: #2563eb;
  border-color: #2563eb;
}

.el-dialog {
  border-radius: 8px;
}

.el-dialog :deep(.el-dialog__header) {
  background-color: #f8fafc;
  border-bottom: 1px solid #e5e7eb;
  padding: 20px 24px;
}

.el-dialog :deep(.el-dialog__title) {
  color: #1f2937;
  font-weight: 600;
}

.el-dialog :deep(.el-dialog__body) {
  padding: 24px;
}

.el-dialog :deep(.el-dialog__footer) {
  padding: 20px 24px;
  border-top: 1px solid #e5e7eb;
  background-color: #f8fafc;
}

.dialog-footer .el-button {
  border-radius: 6px;
  padding: 10px 20px;
  font-weight: 500;
}

.dialog-footer .el-button--primary {
  background-color: #3b82f6;
  border-color: #3b82f6;
}

.dialog-footer .el-button--primary:hover {
  background-color: #2563eb;
  border-color: #2563eb;
}

@media (max-width: 768px) {
  .admin-profile {
    padding: 16px;
  }

  .user-info-display {
    flex-direction: column;
    text-align: center;
    gap: 24px;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .avatar-upload {
    flex-direction: column;
    gap: 12px;
  }
}

@media (max-width: 480px) {
  .profile-card :deep(.el-card__body) {
    padding: 20px 16px;
  }

  .user-name {
    font-size: 20px;
  }

  .info-item {
    padding: 12px;
  }
}
</style>