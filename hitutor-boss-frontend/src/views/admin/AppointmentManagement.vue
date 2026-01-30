<template>
  <div class="appointment-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>预约管理</span>
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
            <el-option label="待确认" value="pending" />
            <el-option label="已确认" value="confirmed" />
            <el-option label="已取消" value="cancelled" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="appointmentList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="预约ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="tutorId" label="家教老师ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.tutorId" />
          </template>
        </el-table-column>
        <el-table-column prop="studentId" label="学生ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.studentId" />
          </template>
        </el-table-column>
        <el-table-column prop="subjectName" label="科目" width="100" />
        <el-table-column prop="appointmentTime" label="预约时间" width="180" />
        <el-table-column prop="duration" label="时长" width="100">
          <template #default="{ row }">
            {{ row.duration }}小时
          </template>
        </el-table-column>
        <el-table-column prop="hourlyRate" label="时薪" width="100">
          <template #default="{ row }">
            ¥{{ row.hourlyRate }}/小时
          </template>
        </el-table-column>
        <el-table-column prop="address" label="上课地址" width="200" show-overflow-tooltip />
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
        <el-table-column label="操作" fixed="right" width="250">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button
              v-if="row.status === 'pending'"
              type="success"
              size="small"
              @click="handleConfirm(row)"
            >
              确认
            </el-button>
            <el-button
              v-if="row.status === 'pending' || row.status === 'confirmed'"
              type="warning"
              size="small"
              @click="handleCancel(row)"
            >
              取消
            </el-button>
            <el-button
              v-if="row.status === 'confirmed'"
              type="success"
              size="small"
              @click="handleComplete(row)"
            >
              完成
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无预约数据" :image-size="80" />
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

    <el-dialog v-model="dialogVisible" title="预约详情" width="700px">
      <el-descriptions v-if="currentAppointment" :column="2" border>
        <el-descriptions-item label="预约ID">{{ currentAppointment.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="家教老师ID">{{ currentAppointment.tutorId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="学生ID">{{ currentAppointment.studentId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="科目">{{ currentAppointment.subjectName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="预约时间">{{ currentAppointment.appointmentTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="时长">{{ currentAppointment.duration || '-' }}小时</el-descriptions-item>
        <el-descriptions-item label="时薪">¥{{ currentAppointment.hourlyRate || '-' }}/小时</el-descriptions-item>
        <el-descriptions-item label="总金额">¥{{ currentAppointment.totalAmount || '-' }}</el-descriptions-item>
        <el-descriptions-item label="上课地址" :span="2">{{ currentAppointment.address || '-' }}</el-descriptions-item>
        <el-descriptions-item label="经纬度">
          {{ currentAppointment.latitude || '-' }}, {{ currentAppointment.longitude || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentAppointment.status)">
            {{ getStatusText(currentAppointment.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ currentAppointment.notes || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentAppointment.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ currentAppointment.updateTime || '-' }}</el-descriptions-item>
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
const appointmentList = ref([])
const subjectList = ref([])
const dialogVisible = ref(false)
const currentAppointment = ref(null)

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
    pending: 'warning',
    confirmed: 'primary',
    cancelled: 'danger',
    completed: 'success'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待确认',
    confirmed: '已确认',
    cancelled: '已取消',
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
    ElMessage.error('获取科目列表失败')
  }
}

const fetchAppointmentList = async () => {
  loading.value = true
  try {
    const response = await api.appointment.getAppointmentsByUserId('all')
    if (response.success) {
      appointmentList.value = response.data || []
      pagination.total = response.data?.length || 0
    } else {
      ElMessage.error(response.message || '获取预约列表失败')
    }
  } catch (error) {
    ElMessage.error('获取预约列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchAppointmentList()
}

const handleReset = () => {
  searchForm.subject = ''
  searchForm.status = ''
  pagination.page = 1
  fetchAppointmentList()
}

const handleView = (row) => {
  currentAppointment.value = row
  dialogVisible.value = true
}

const handleConfirm = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要确认预约 #${row.id} 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'success'
      }
    )

    const response = await api.appointment.confirmAppointment(row.id)
    if (response.success) {
      ElMessage.success('预约已确认')
      fetchAppointmentList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

const handleCancel = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要取消预约 #${row.id} 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.appointment.cancelAppointment(row.id)
    if (response.success) {
      ElMessage.success('预约已取消')
      fetchAppointmentList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

const handleComplete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要完成预约 #${row.id} 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'success'
      }
    )

    const response = await api.appointment.completeAppointment(row.id)
    if (response.success) {
      ElMessage.success('预约已完成')
      fetchAppointmentList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

const handleSizeChange = (size) => {
  pagination.size = size
  fetchAppointmentList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchAppointmentList()
}

onMounted(() => {
  fetchSubjectList()
  fetchAppointmentList()
})
</script>

<style scoped>
.appointment-management {
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