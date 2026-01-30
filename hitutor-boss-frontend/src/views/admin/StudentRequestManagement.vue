<template>
  <div class="student-request-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学生需求管理</span>
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
            <el-option label="招募中" value="recruiting" />
            <el-option label="已匹配" value="matched" />
            <el-option label="已关闭" value="closed" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="requestList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="需求ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.userId" />
          </template>
        </el-table-column>
        <el-table-column prop="childName" label="孩子称呼" width="100">
          <template #default="{ row }">
            {{ row.childName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="childGrade" label="孩子年级" width="100">
          <template #default="{ row }">
            {{ row.childGrade || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="subjectName" label="科目" width="100">
          <template #default="{ row }">
            {{ row.subjectName || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="时薪范围" width="180">
          <template #default="{ row }">
            ¥{{ row.hourlyRateMin || '-' }} - ¥{{ row.hourlyRateMax || '-' }}/小时
          </template>
        </el-table-column>
        <el-table-column prop="address" label="家教地址" width="200" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.address || '-' }}
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
        <el-table-column label="操作" fixed="right" width="200">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无学生需求数据" :image-size="80" />
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

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px">
      <el-descriptions v-if="isViewMode && currentRequest" :column="2" border>
        <el-descriptions-item label="需求ID">{{ currentRequest.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="用户ID">{{ currentRequest.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="孩子称呼">{{ currentRequest.childName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="孩子年级">{{ currentRequest.childGrade || '-' }}</el-descriptions-item>
        <el-descriptions-item label="科目">{{ currentRequest.subjectName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="时薪范围">
          ¥{{ currentRequest.hourlyRateMin || '-' }} - ¥{{ currentRequest.hourlyRateMax || '-' }}/小时
        </el-descriptions-item>
        <el-descriptions-item label="家教地址" :span="2">{{ currentRequest.address || '-' }}</el-descriptions-item>
        <el-descriptions-item label="经纬度">
          {{ currentRequest.latitude || '-' }}, {{ currentRequest.longitude || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="可上课时间">{{ currentRequest.availableTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="教学要求" :span="2">{{ currentRequest.requirements || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentRequest.status)">
            {{ getStatusText(currentRequest.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentRequest.createTime || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-form v-else :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="孩子称呼" prop="childName">
          <el-input v-model="formData.childName" placeholder="请输入孩子称呼" />
        </el-form-item>
        <el-form-item label="孩子年级" prop="childGrade">
          <el-input v-model="formData.childGrade" placeholder="请输入孩子年级" />
        </el-form-item>
        <el-form-item label="科目" prop="subjectName">
          <el-input v-model="formData.subjectName" placeholder="请输入科目" />
        </el-form-item>
        <el-form-item label="最低时薪" prop="hourlyRateMin">
          <el-input-number v-model="formData.hourlyRateMin" :min="0" :max="500" :precision="2" placeholder="请输入最低时薪" />
        </el-form-item>
        <el-form-item label="最高时薪" prop="hourlyRateMax">
          <el-input-number v-model="formData.hourlyRateMax" :min="0" :max="500" :precision="2" placeholder="请输入最高时薪" />
        </el-form-item>
        <el-form-item label="家教地址" prop="address">
          <el-input v-model="formData.address" placeholder="请输入家教地址" />
        </el-form-item>
        <el-form-item label="经度" prop="longitude">
          <el-input-number v-model="formData.longitude" :precision="6" placeholder="请输入经度" />
        </el-form-item>
        <el-form-item label="纬度" prop="latitude">
          <el-input-number v-model="formData.latitude" :precision="6" placeholder="请输入纬度" />
        </el-form-item>
        <el-form-item label="可上课时间" prop="availableTime">
          <el-input v-model="formData.availableTime" type="textarea" :rows="2" placeholder="请输入可上课时间" />
        </el-form-item>
        <el-form-item label="教学要求" prop="requirements">
          <el-input v-model="formData.requirements" type="textarea" :rows="3" placeholder="请输入教学要求" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择状态">
            <el-option label="招募中" value="recruiting" />
            <el-option label="已匹配" value="matched" />
            <el-option label="已关闭" value="closed" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer v-if="!isViewMode">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
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
const requestList = ref([])
const subjectList = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('学生需求详情')
const isViewMode = ref(true)
const currentRequest = ref(null)
const formRef = ref(null)

const searchForm = reactive({
  subject: '',
  status: ''
})

const formData = reactive({
  id: null,
  userId: '',
  childName: '',
  childGrade: '',
  subjectName: '',
  hourlyRateMin: 0,
  hourlyRateMax: 0,
  address: '',
  latitude: 0,
  longitude: 0,
  availableTime: '',
  requirements: '',
  status: 'recruiting'
})

const formRules = {
  childName: [{ required: true, message: '请输入孩子称呼', trigger: 'blur' }],
  childGrade: [{ required: true, message: '请输入孩子年级', trigger: 'blur' }],
  subjectName: [{ required: true, message: '请输入科目', trigger: 'blur' }],
  hourlyRateMin: [{ required: true, message: '请输入最低时薪', trigger: 'blur' }],
  hourlyRateMax: [{ required: true, message: '请输入最高时薪', trigger: 'blur' }],
  address: [{ required: true, message: '请输入家教地址', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const getStatusType = (status) => {
  const types = {
    recruiting: 'primary',
    matched: 'warning',
    closed: 'info',
    completed: 'success'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    recruiting: '招募中',
    matched: '已匹配',
    closed: '已关闭',
    completed: '已完成'
  }
  return texts[status] || status
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
  }
}

const fetchRequestList = async () => {
  loading.value = true
  try {
    const response = await api.studentRequest.getAllStudentRequests({
      page: pagination.page,
      size: pagination.size
    })
    if (response.success) {
      requestList.value = response.data?.content || []
      pagination.total = response.data?.totalElements || 0
    } else {
      ElMessage.error(response.message || '获取需求列表失败')
    }
  } catch (error) {
    ElMessage.error('获取需求列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchRequestList()
}

const handleReset = () => {
  searchForm.subject = ''
  searchForm.status = ''
  pagination.page = 1
  fetchRequestList()
}

const handleView = (row) => {
  currentRequest.value = row
  dialogTitle.value = '学生需求详情'
  isViewMode.value = true
  dialogVisible.value = true
}

const handleEdit = (row) => {
  Object.assign(formData, row)
  dialogTitle.value = '编辑学生需求'
  isViewMode.value = false
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除学生需求 #${row.id} 吗？此操作不可恢复。`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.studentRequest.deleteStudentRequest(row.id)
    if (response.success) {
      ElMessage.success('删除成功')
      fetchRequestList()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    const response = await api.studentRequest.updateStudentRequest(formData.id, formData)
    if (response.success) {
      ElMessage.success('保存成功')
      dialogVisible.value = false
      fetchRequestList()
    } else {
      ElMessage.error(response.message || '保存失败')
    }
  } catch (error) {
    if (error !== false) {
      ElMessage.error('请填写完整信息')
    }
  }
}

const handleSizeChange = (size) => {
  pagination.size = size
  fetchRequestList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchRequestList()
}

onMounted(() => {
  fetchSubjectList()
  fetchRequestList()
})
</script>

<style scoped>
.student-request-management {
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
