<template>
  <div class="tutor-resume-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>家教简历管理</span>
        </div>
      </template>

      <el-table :data="resumeList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="简历ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.userId" />
          </template>
        </el-table-column>
        <el-table-column prop="teachingExperience" label="教学年限" width="120">
          <template #default="{ row }">
            {{ row.teachingExperience }}年
          </template>
        </el-table-column>
        <el-table-column prop="teachingStyle" label="教学风格" width="200" show-overflow-tooltip />
        <el-table-column prop="specialties" label="擅长科目" width="200" show-overflow-tooltip />
        <el-table-column prop="achievements" label="教学成就" width="200" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.updateTime) }}
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
          <el-empty description="暂无简历数据" :image-size="80" />
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
      <el-descriptions v-if="isViewMode && currentResume" :column="2" border>
        <el-descriptions-item label="简历ID">{{ currentResume.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="用户ID">{{ currentResume.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="教学年限">{{ currentResume.teachingExperience || '-' }}年</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ formatDateTime(currentResume.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="教学风格" :span="2">{{ currentResume.teachingStyle || '-' }}</el-descriptions-item>
        <el-descriptions-item label="擅长科目" :span="2">{{ currentResume.specialties || '-' }}</el-descriptions-item>
        <el-descriptions-item label="教学成就" :span="2">{{ currentResume.achievements || '-' }}</el-descriptions-item>
        <el-descriptions-item label="更新时间" :span="2">{{ formatDateTime(currentResume.updateTime) }}</el-descriptions-item>
      </el-descriptions>

      <el-form v-else :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="formData.userId" placeholder="请输入用户ID" />
        </el-form-item>
        <el-form-item label="教学年限" prop="teachingExperience">
          <el-input-number v-model="formData.teachingExperience" :min="0" :max="50" placeholder="请输入教学年限" />
        </el-form-item>
        <el-form-item label="教学风格" prop="teachingStyle">
          <el-input v-model="formData.teachingStyle" type="textarea" :rows="3" placeholder="请输入教学风格" />
        </el-form-item>
        <el-form-item label="擅长科目" prop="specialties">
          <el-input v-model="formData.specialties" type="textarea" :rows="3" placeholder="请输入擅长科目" />
        </el-form-item>
        <el-form-item label="教学成就" prop="achievements">
          <el-input v-model="formData.achievements" type="textarea" :rows="3" placeholder="请输入教学成就" />
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
const resumeList = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('家教简历详情')
const isViewMode = ref(true)
const currentResume = ref(null)
const formRef = ref(null)

const formData = reactive({
  id: null,
  userId: '',
  teachingExperience: 0,
  teachingStyle: '',
  specialties: '',
  achievements: ''
})

const formRules = {
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  teachingExperience: [{ required: true, message: '请输入教学年限', trigger: 'blur' }],
  teachingStyle: [{ required: true, message: '请输入教学风格', trigger: 'blur' }],
  specialties: [{ required: true, message: '请输入擅长科目', trigger: 'blur' }],
  achievements: [{ required: true, message: '请输入教学成就', trigger: 'blur' }]
}

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

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

const fetchResumeList = async () => {
  loading.value = true
  try {
    const response = await api.tutorResume.getAllTutorResumes({
      page: pagination.page - 1,
      size: pagination.size
    })
    if (response.success) {
      resumeList.value = response.data?.content || []
      pagination.total = response.data?.totalElements || 0
    } else {
      ElMessage.error(response.message || '获取简历列表失败')
    }
  } catch (error) {
    ElMessage.error('获取简历列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = (row) => {
  currentResume.value = row
  dialogTitle.value = '家教简历详情'
  isViewMode.value = true
  dialogVisible.value = true
}

const handleEdit = (row) => {
  Object.assign(formData, row)
  dialogTitle.value = '编辑家教简历'
  isViewMode.value = false
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除简历 #${row.id} 吗？此操作不可恢复。`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.tutorResume.deleteTutorResume(row.id)
    if (response.success) {
      ElMessage.success('删除成功')
      fetchResumeList()
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
    
    const response = await api.tutorResume.updateTutorResume(formData.id, formData)
    if (response.success) {
      ElMessage.success('保存成功')
      dialogVisible.value = false
      fetchResumeList()
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
  fetchResumeList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchResumeList()
}

onMounted(() => {
  fetchResumeList()
})
</script>

<style scoped>
.tutor-resume-management {
  padding: 0;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
