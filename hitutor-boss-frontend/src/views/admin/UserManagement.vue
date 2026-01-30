<template>
  <div class="user-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="角色">
          <el-select v-model="searchForm.role" placeholder="全部角色" clearable>
            <el-option label="全部" value="" />
            <el-option label="学生" value="student" />
            <el-option label="家教老师" value="tutor" />
            <el-option label="管理员" value="admin" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="全部" value="" />
            <el-option label="活跃" value="active" />
            <el-option label="禁用" value="inactive" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="handleAddUser">添加用户</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="userList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="用户ID" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.id ? (row.id.length > 4 ? row.id.substring(0, 4) + '...' : row.id) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" min-width="100" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.username || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" min-width="110" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.phone || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.email || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="role" label="角色" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag :type="getRoleType(row.role)">{{ getRoleText(row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
              {{ row.status === 'active' ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="badge" label="头衔" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag v-if="row.badge" type="warning">{{ row.badge }}</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="gender" label="性别" width="80" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag v-if="row.gender === 'male'" type="primary">男</el-tag>
            <el-tag v-else-if="row.gender === 'female'" type="danger">女</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginTime" label="最后登录时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatDateTime(row.lastLoginTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginIp" label="最后登录IP" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.lastLoginIp || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="400" show-overflow-tooltip>
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="warning" size="small" @click="handleAdjustPoints(row)">调整积分</el-button>
            <el-button type="info" size="small" @click="handleResetPassword(row)">重置密码</el-button>
            <el-button type="success" size="small" @click="handleSetBadge(row)">赐予头衔</el-button>
            <el-button
              :type="row.status === 'active' ? 'danger' : 'success'"
              size="small"
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 'active' ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无用户数据" :image-size="80" />
        </template>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <el-dialog v-model="dialogVisible" title="用户详情" width="600px">
      <el-descriptions v-if="currentUser" :column="2" border>
        <el-descriptions-item label="用户ID">
          {{ currentUser.id ? (currentUser.id.length > 4 ? currentUser.id.substring(0, 4) + '...' : currentUser.id) : '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="用户名">{{ currentUser.username || '-' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentUser.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ currentUser.email || '-' }}</el-descriptions-item>
        <el-descriptions-item label="头衔">
          <el-tag v-if="currentUser.badge" type="warning">{{ currentUser.badge }}</el-tag>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="角色">
          <el-tag :type="getRoleType(currentUser.role)">{{ getRoleText(currentUser.role) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="currentUser.status === 'active' ? 'success' : 'danger'">
            {{ currentUser.status === 'active' ? '活跃' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="性别">{{ currentUser.gender || '-' }}</el-descriptions-item>
        <el-descriptions-item label="出生日期">{{ currentUser.birthDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="教学经验">{{ currentUser.teachingExperience || '-' }}年</el-descriptions-item>
        <el-descriptions-item label="积分">{{ currentUser.points || 0 }}</el-descriptions-item>
        <el-descriptions-item label="最后登录时间">{{ formatDateTime(currentUser.lastLoginTime) }}</el-descriptions-item>
        <el-descriptions-item label="最后登录IP">{{ currentUser.lastLoginIp || '-' }}</el-descriptions-item>
        <el-descriptions-item label="注册时间" :span="2">{{ formatDateTime(currentUser.createTime) }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <el-dialog v-model="pointsDialogVisible" title="调整积分" width="500px">
      <el-form v-if="pointsForm" :model="pointsForm" label-width="100px">
        <el-form-item label="用户ID">
          {{ pointsForm.userId ? (pointsForm.userId.length > 4 ? pointsForm.userId.substring(0, 4) + '...' : pointsForm.userId) : '-' }}
        </el-form-item>
        <el-form-item label="用户名">
          <span>{{ pointsForm.username }}</span>
        </el-form-item>
        <el-form-item label="当前积分">
          <span>{{ pointsForm.currentPoints }}</span>
        </el-form-item>
        <el-form-item label="调整类型">
          <el-radio-group v-model="pointsForm.type">
            <el-radio label="add">增加</el-radio>
            <el-radio label="deduct">扣除</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="积分类型">
          <el-select v-model="pointsForm.pointType" placeholder="请选择积分类型">
            <el-option label="奖励" value="reward" />
            <el-option label="惩罚" value="penalty" />
            <el-option label="补偿" value="compensation" />
            <el-option label="活动" value="activity" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="积分数量">
          <el-input-number v-model="pointsForm.points" :min="1" :max="10000" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="pointsForm.description" type="textarea" :rows="3" placeholder="请输入调整说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pointsDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmPoints">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="badgeDialogVisible" title="赐予头衔" width="500px">
      <el-form v-if="badgeForm" :model="badgeForm" label-width="100px">
        <el-form-item label="用户ID">
          {{ badgeForm.userId ? (badgeForm.userId.length > 4 ? badgeForm.userId.substring(0, 4) + '...' : badgeForm.userId) : '-' }}
        </el-form-item>
        <el-form-item label="用户名">
          <span>{{ badgeForm.username }}</span>
        </el-form-item>
        <el-form-item label="当前头衔">
          <el-tag v-if="badgeForm.currentBadge" type="warning">{{ badgeForm.currentBadge }}</el-tag>
          <span v-else>-</span>
        </el-form-item>
        <el-form-item label="新头衔">
          <el-input v-model="badgeForm.badge" placeholder="请输入头衔，留空则移除头衔" maxlength="8" show-word-limit />
        </el-form-item>
        <el-form-item label="推荐头衔">
          <div class="badge-suggestions">
            <el-tag
              v-for="suggestion in badgeSuggestions"
              :key="suggestion"
              class="badge-suggestion"
              @click="badgeForm.badge = suggestion"
              style="cursor: pointer; margin-right: 8px; margin-bottom: 8px;"
            >
              {{ suggestion }}
            </el-tag>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="badgeDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmBadge">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="addUserDialogVisible" title="添加用户" width="600px">
      <el-form v-if="addUserForm" :model="addUserForm" :rules="addUserRules" ref="addUserFormRef" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="addUserForm.username" placeholder="请输入用户名" maxlength="50" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="addUserForm.email" placeholder="请输入邮箱" maxlength="100" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="addUserForm.password" type="password" placeholder="请输入密码" show-password maxlength="50" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="addUserForm.phone" placeholder="请输入手机号" maxlength="20" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="addUserForm.role" placeholder="请选择角色">
            <el-option label="学生" value="student" />
            <el-option label="家教老师" value="tutor" />
            <el-option label="管理员" value="admin" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addUserDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmAddUser">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

import api from '@/services/api'

const loading = ref(false)
const userList = ref([])
const dialogVisible = ref(false)
const currentUser = ref(null)
const pointsDialogVisible = ref(false)
const pointsForm = ref(null)
const badgeDialogVisible = ref(false)
const badgeForm = ref(null)
const addUserDialogVisible = ref(false)
const addUserForm = ref(null)
const addUserFormRef = ref(null)

const badgeSuggestions = [
  '金牌家教',
  '优秀家教',
  '资深家教',
  '明星家教',
  '人气家教',
  '好评家教',
  '认证家教',
  '金牌学员',
  '优秀学员',
  '活跃学员'
]

const addUserRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 50, message: '用户名长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 50, message: '密码长度在 6 到 50 个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

const searchForm = reactive({
  role: '',
  status: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const getRoleType = (role) => {
  const types = {
    admin: 'danger',
    tutor: 'warning',
    student: 'success'
  }
  return types[role] || 'info'
}

const getRoleText = (role) => {
  const texts = {
    admin: '管理员',
    tutor: '家教老师',
    student: '学生'
  }
  return texts[role] || role
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  const date = new Date(dateTime)
  if (isNaN(date.getTime())) return '-'
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

const fetchUserList = async () => {
  loading.value = true
  try {
    const response = await api.admin.getUserList({
      page: pagination.page,
      size: pagination.size
    })
    if (response.success) {
      const { users, total } = response.data
      userList.value = users || []
      pagination.total = total || 0
    } else {
      ElMessage.error(response.message || '获取用户列表失败')
    }
  } catch (error) {
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchUserList()
}

const handleReset = () => {
  searchForm.role = ''
  searchForm.status = ''
  pagination.page = 1
  fetchUserList()
}

const handleView = (row) => {
  currentUser.value = row
  dialogVisible.value = true
}

const handleToggleStatus = async (row) => {
  const newStatus = row.status === 'active' ? 'inactive' : 'active'
  const actionText = newStatus === 'active' ? '启用' : '禁用'

  try {
    await ElMessageBox.confirm(
      `确定要${actionText}用户 ${row.username} 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.admin.updateUserStatus(row.id, newStatus)
    if (response.success) {
      ElMessage.success(`${actionText}成功`)
      fetchUserList()
    } else {
      ElMessage.error(response.message || `${actionText}失败`)
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`${actionText}失败`)
    }
  }
}

const handleAdjustPoints = (row) => {
  pointsForm.value = {
    userId: row.id,
    username: row.username,
    currentPoints: row.points || 0,
    type: 'add',
    points: 10,
    pointType: 'reward',
    description: ''
  }
  pointsDialogVisible.value = true
}

const handleResetPassword = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要重置用户 ${row.username} 的密码为 123456 吗？`,
      '重置密码',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.admin.resetUserPassword(row.id)
    if (response.success) {
      ElMessage.success(response.message || '密码重置成功')
    } else {
      ElMessage.error(response.message || '密码重置失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('密码重置失败')
    }
  }
}

const handleSetBadge = (row) => {
  badgeForm.value = {
    userId: row.id,
    username: row.username,
    currentBadge: row.badge || '',
    badge: row.badge || ''
  }
  badgeDialogVisible.value = true
}

const handleConfirmBadge = async () => {
  try {
    const response = await api.admin.setUserBadge(badgeForm.value.userId, badgeForm.value.badge)
    if (response.success) {
      ElMessage.success(response.message || '头衔设置成功')
      badgeDialogVisible.value = false
      fetchUserList()
    } else {
      ElMessage.error(response.message || '头衔设置失败')
    }
  } catch (error) {
    ElMessage.error('头衔设置失败')
  }
}

const handleAddUser = () => {
  addUserForm.value = {
    username: '',
    email: '',
    password: '',
    phone: '',
    role: 'student'
  }
  addUserDialogVisible.value = true
}

const handleConfirmAddUser = async () => {
  if (!addUserFormRef.value) return

  try {
    await addUserFormRef.value.validate()
  } catch (error) {
    return
  }

  try {
    const response = await api.admin.createUser({
      username: addUserForm.value.username,
      email: addUserForm.value.email,
      password: addUserForm.value.password,
      phone: addUserForm.value.phone,
      role: addUserForm.value.role
    })

    if (response.success) {
      ElMessage.success(response.message || '添加用户成功')
      addUserDialogVisible.value = false
      fetchUserList()
    } else {
      ElMessage.error(response.message || '添加用户失败')
    }
  } catch (error) {
    ElMessage.error(error.message || '添加用户失败')
  }
}

const handleConfirmPoints = async () => {
  if (!pointsForm.value.description.trim()) {
    ElMessage.warning('请输入调整说明')
    return
  }

  try {
    let response
    if (pointsForm.value.type === 'add') {
      response = await api.point.adminAddPoints({
        userId: pointsForm.value.userId,
        points: pointsForm.value.points,
        type: pointsForm.value.pointType,
        description: pointsForm.value.description
      })
    } else {
      response = await api.point.adminDeductPoints({
        userId: pointsForm.value.userId,
        points: pointsForm.value.points,
        type: pointsForm.value.pointType,
        description: pointsForm.value.description
      })
    }

    if (response.success) {
      ElMessage.success('积分调整成功')
      pointsDialogVisible.value = false
      fetchUserList()
    } else {
      ElMessage.error(response.message || '积分调整失败')
    }
  } catch (error) {
    ElMessage.error('积分调整失败')
  }
}

const handleSizeChange = (size) => {
  pagination.size = size
  fetchUserList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchUserList()
}

onMounted(() => {
  fetchUserList()
})
</script>

<style scoped>
.user-management {
  padding: 0;
}

.search-form {
  margin-bottom: 20px;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
