<template>
  <div class="tutor-profile-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>家教信息管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="科目">
          <el-select v-model="searchForm.subject" placeholder="全部科目" clearable>
            <el-option label="全部" value="" />
            <el-option v-for="subject in subjectList" :key="subject.id" :label="subject.name" :value="subject.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="全部" value="" />
            <el-option label="可用" value="available" />
            <el-option label="忙碌" value="busy" />
            <el-option label="不可用" value="inactive" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="profileList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="信息ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.userId" />
          </template>
        </el-table-column>
        <el-table-column prop="subjectName" label="科目" width="100">
          <template #default="{ row }">
            {{ row.subjectName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="hourlyRate" label="时薪" width="100">
          <template #default="{ row }">
            ¥{{ row.hourlyRate || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="address" label="授课地址" width="200" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.address || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="targetGradeLevels" label="目标年级" width="150" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatGradeLevels(row.targetGradeLevels) }}
          </template>
        </el-table-column>
        <el-table-column prop="availableTime" label="可授课时间" width="150" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.availableTime || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
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

    <el-dialog v-model="dialogVisible" title="家教信息详情" width="700px">
      <el-descriptions v-if="currentProfile" :column="2" border>
        <el-descriptions-item label="信息ID">{{ currentProfile.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="用户ID">{{ currentProfile.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="科目">{{ currentProfile.subjectName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="时薪">¥{{ currentProfile.hourlyRate || '-' }}/小时</el-descriptions-item>
        <el-descriptions-item label="授课地址" :span="2">{{ currentProfile.address || '-' }}</el-descriptions-item>
        <el-descriptions-item label="经纬度">
          {{ currentProfile.latitude || '-' }}, {{ currentProfile.longitude || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="可授课时间">{{ currentProfile.availableTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="目标年级" :span="2">{{ formatGradeLevels(currentProfile.targetGradeLevels) }}</el-descriptions-item>
        <el-descriptions-item label="描述" :span="2">{{ currentProfile.description || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentProfile.status)">
            {{ getStatusText(currentProfile.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentProfile.createTime || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import IdDisplay from '@/components/IdDisplay.vue'
import api from '@/services/api'

const loading = ref(false)
const profileList = ref([])
const subjectList = ref([])
const dialogVisible = ref(false)
const currentProfile = ref(null)

const searchForm = reactive({
  subject: '',
  status: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const getStatusType = (status) => {
  const types = {
    available: 'success',
    busy: 'warning',
    inactive: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    available: '可用',
    busy: '忙碌',
    inactive: '不可用'
  }
  return texts[status] || status
}

const formatGradeLevels = (gradeLevels) => {
  if (!gradeLevels) return '-'
  
  const gradeMap = {
    'preschool': '学前',
    'primary': '小学',
    'junior_high': '初中',
    'senior_high': '高中'
  }
  
  const levels = gradeLevels.split(',').map(level => level.trim())
  return levels.map(level => gradeMap[level] || level).join(', ')
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

const fetchSubjectList = async () => {
  try {
    const response = await api.subject.getAllSubjects()
    if (response.success) {
      subjectList.value = response.data || []
    }
  } catch (error) {
    ElMessage.error('获取科目列表失败')
  }
}

const fetchProfileList = async () => {
  loading.value = true
  try {
    const response = await api.tutorProfile.getAllTutorProfiles({
      page: pagination.page,
      size: pagination.size
    })
    if (response.success) {
      profileList.value = response.data?.content || []
      pagination.total = response.data?.totalElements || 0
    } else {
      ElMessage.error(response.message || '获取家教信息列表失败')
    }
  } catch (error) {
    ElMessage.error('获取家教信息列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchProfileList()
}

const handleReset = () => {
  searchForm.subject = ''
  searchForm.status = ''
  pagination.page = 1
  fetchProfileList()
}

const handleView = (row) => {
  currentProfile.value = row
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除家教信息 #${row.id} 吗？此操作不可恢复。`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.tutorProfile.deleteTutorProfile(row.id)
    if (response.success) {
      ElMessage.success('删除成功')
      fetchProfileList()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSizeChange = (size) => {
  pagination.size = size
  fetchProfileList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchProfileList()
}

onMounted(() => {
  fetchSubjectList()
  fetchProfileList()
})
</script>

<style scoped>
.tutor-profile-management {
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
