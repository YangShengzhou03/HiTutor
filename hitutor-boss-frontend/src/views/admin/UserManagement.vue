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
        </el-form-item>
      </el-form>

      <el-table :data="userList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="用户ID" width="200">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" width="120">
          <template #default="{ row }">
            {{ row.username || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" width="120">
          <template #default="{ row }">
            {{ row.phone || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" width="180">
          <template #default="{ row }">
            {{ row.email || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="role" label="角色" width="100">
          <template #default="{ row }">
            <el-tag :type="getRoleType(row.role)">{{ getRoleText(row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
              {{ row.status === 'active' ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="isVerified" label="已认证" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isVerified ? 'success' : 'info'">
              {{ row.isVerified ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginTime" label="最后登录时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.lastLoginTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginIp" label="最后登录IP" width="140">
          <template #default="{ row }">
            {{ row.lastLoginIp || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="260">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="warning" size="small" @click="handleAdjustPoints(row)">调整积分</el-button>
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
          <IdDisplay :id="currentUser.id" />
        </el-descriptions-item>
        <el-descriptions-item label="用户名">{{ currentUser.username || '-' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentUser.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ currentUser.email || '-' }}</el-descriptions-item>
        <el-descriptions-item label="角色">
          <el-tag :type="getRoleType(currentUser.role)">{{ getRoleText(currentUser.role) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="currentUser.status === 'active' ? 'success' : 'danger'">
            {{ currentUser.status === 'active' ? '活跃' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="已认证">
          <el-tag :type="currentUser.isVerified ? 'success' : 'info'">
            {{ currentUser.isVerified ? '是' : '否' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="性别">{{ currentUser.gender || '-' }}</el-descriptions-item>
        <el-descriptions-item label="出生日期">{{ currentUser.birthDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="学历">{{ currentUser.education || '-' }}</el-descriptions-item>
        <el-descriptions-item label="学校">{{ currentUser.school || '-' }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ currentUser.major || '-' }}</el-descriptions-item>
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
          <IdDisplay :id="pointsForm.userId" />
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import IdDisplay from '@/components/IdDisplay.vue'
import api from '@/services/api'

const loading = ref(false)
const userList = ref([])
const dialogVisible = ref(false)
const currentUser = ref(null)
const pointsDialogVisible = ref(false)
const pointsForm = ref(null)

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
