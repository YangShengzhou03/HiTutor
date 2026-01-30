<template>
  <div class="point-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>积分管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="用户ID">
          <el-input v-model="searchForm.userId" placeholder="请输入用户ID" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="userList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="用户ID" width="120">
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
        <el-table-column prop="points" label="当前积分" width="120">
          <template #default="{ row }">
            <span :style="{ color: row.points >= 0 ? '#67C23A' : '#F56C6C', fontWeight: 'bold' }">
              {{ row.points || 0 }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="300">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleAddPoints(row)">发放积分</el-button>
            <el-button type="warning" size="small" @click="handleDeductPoints(row)">扣除积分</el-button>
            <el-button type="info" size="small" @click="handleViewRecords(row)">查看记录</el-button>
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

    <el-dialog v-model="pointDialogVisible" :title="pointDialogTitle" width="500px">
      <el-form :model="pointForm" :rules="pointFormRules" ref="pointFormRef" label-width="100px">
        <el-form-item label="用户ID">
          <el-input v-model="pointForm.userId" disabled />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="pointForm.username" disabled />
        </el-form-item>
        <el-form-item label="积分数量" prop="points">
          <el-input-number v-model="pointForm.points" :min="1" :max="10000" />
        </el-form-item>
        <el-form-item label="积分类型" prop="type">
          <el-select v-model="pointForm.type" placeholder="请选择积分类型">
            <el-option label="奖励" value="reward" />
            <el-option label="惩罚" value="penalty" />
            <el-option label="补偿" value="compensation" />
            <el-option label="活动" value="activity" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="说明" prop="description">
          <el-input v-model="pointForm.description" type="textarea" :rows="3" placeholder="请输入积分操作说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pointDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitPoints">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="recordsDialogVisible" title="积分记录" width="800px">
      <el-table :data="pointRecords" border style="width: 100%" v-loading="recordsLoading">
        <el-table-column prop="id" label="记录ID" width="100" />
        <el-table-column prop="points" label="积分变化" width="100">
          <template #default="{ row }">
            <span :style="{ color: row.points >= 0 ? '#67C23A' : '#F56C6C', fontWeight: 'bold' }">
              {{ row.points >= 0 ? '+' : '' }}{{ row.points }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)">{{ getTypeText(row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="说明" min-width="200" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无积分记录" :image-size="80" />
        </template>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import IdDisplay from '@/components/IdDisplay.vue'
import api from '@/services/api'

const loading = ref(false)
const recordsLoading = ref(false)
const userList = ref([])
const pointRecords = ref([])
const pointDialogVisible = ref(false)
const recordsDialogVisible = ref(false)
const pointDialogTitle = ref('')
const pointFormRef = ref(null)

const searchForm = reactive({
  userId: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const pointForm = reactive({
  userId: '',
  username: '',
  points: 1,
  type: 'reward',
  description: ''
})

const pointFormRules = {
  points: [
    { required: true, message: '请输入积分数量', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择积分类型', trigger: 'change' }
  ],
  description: [
    { required: true, message: '请输入积分说明', trigger: 'blur' },
    { min: 2, max: 200, message: '说明长度在 2 到 200 个字符', trigger: 'blur' }
  ]
}

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

const getTypeTagType = (type) => {
  const types = {
    login: 'success',
    reward: 'success',
    compensation: 'warning',
    penalty: 'danger',
    activity: 'primary',
    other: 'info'
  }
  return types[type] || 'info'
}

const getTypeText = (type) => {
  const texts = {
    login: '登录',
    reward: '奖励',
    compensation: '补偿',
    penalty: '惩罚',
    activity: '活动',
    other: '其他'
  }
  return texts[type] || type
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
  searchForm.userId = ''
  pagination.page = 1
  fetchUserList()
}

const handleAddPoints = (row) => {
  pointDialogTitle.value = '发放积分'
  pointForm.userId = row.id
  pointForm.username = row.username
  pointForm.points = 1
  pointForm.type = 'reward'
  pointForm.description = ''
  pointDialogVisible.value = true
}

const handleDeductPoints = (row) => {
  pointDialogTitle.value = '扣除积分'
  pointForm.userId = row.id
  pointForm.username = row.username
  pointForm.points = 1
  pointForm.type = 'penalty'
  pointForm.description = ''
  pointDialogVisible.value = true
}

const handleSubmitPoints = async () => {
  if (!pointFormRef.value) return
  
  await pointFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    try {
      const isAdd = pointDialogTitle.value === '发放积分'
      const response = isAdd 
        ? await api.point.adminAddPoints({
            userId: pointForm.userId,
            points: pointForm.points,
            type: pointForm.type,
            description: pointForm.description
          })
        : await api.point.adminDeductPoints({
            userId: pointForm.userId,
            points: pointForm.points,
            type: pointForm.type,
            description: pointForm.description
          })
      
      if (response.success) {
        ElMessage.success(isAdd ? '发放积分成功' : '扣除积分成功')
        pointDialogVisible.value = false
        fetchUserList()
      } else {
        ElMessage.error(response.message || '操作失败')
      }
    } catch (error) {
      ElMessage.error('操作失败')
    }
  })
}

const handleViewRecords = async (row) => {
  recordsDialogVisible.value = true
  recordsLoading.value = true
  try {
    const response = await api.point.getPointRecords(row.id)
    if (response.success) {
      pointRecords.value = response.data || []
    } else {
      ElMessage.error(response.message || '获取积分记录失败')
    }
  } catch (error) {
    ElMessage.error('获取积分记录失败')
  } finally {
    recordsLoading.value = false
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
.point-management {
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
