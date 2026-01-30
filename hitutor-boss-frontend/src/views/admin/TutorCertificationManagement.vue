<template>
  <div class="certification-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>家教认证审核</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="全部" value="" />
            <el-option label="待审核" value="pending" />
            <el-option label="已通过" value="approved" />
            <el-option label="已拒绝" value="rejected" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="certificationList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="认证ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.userId" />
          </template>
        </el-table-column>
        <el-table-column prop="realName" label="真实姓名" width="120" />
        <el-table-column prop="idCard" label="身份证号" width="180" />
        <el-table-column prop="education" label="学历" width="100" />
        <el-table-column prop="school" label="毕业院校" width="150" />
        <el-table-column prop="major" label="专业" width="180" />
        <el-table-column prop="certificateNumber" label="教师资格证号" width="160" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="申请时间" width="180">
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
              @click="handleApprove(row)"
            >
              通过
            </el-button>
            <el-button
              v-if="row.status === 'pending'"
              type="danger"
              size="small"
              @click="handleReject(row)"
            >
              拒绝
            </el-button>
            <el-button
              v-if="row.status === 'approved'"
              type="warning"
              size="small"
              @click="handleRevoke(row)"
            >
              吊销
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无认证数据" :image-size="80" />
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

    <el-dialog v-model="dialogVisible" title="认证详情" width="700px">
      <el-descriptions v-if="currentCertification" :column="2" border>
        <el-descriptions-item label="认证ID">{{ currentCertification.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="用户ID">{{ currentCertification.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="真实姓名">{{ currentCertification.realName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="身份证号">{{ currentCertification.idCard || '-' }}</el-descriptions-item>
        <el-descriptions-item label="学历">{{ currentCertification.education || '-' }}</el-descriptions-item>
        <el-descriptions-item label="毕业院校">{{ currentCertification.school || '-' }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ currentCertification.major || '-' }}</el-descriptions-item>
        <el-descriptions-item label="教师资格证号">
          {{ currentCertification.certificateNumber || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentCertification.status)">
            {{ getStatusText(currentCertification.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="申请时间">{{ currentCertification.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ currentCertification.updateTime || '-' }}</el-descriptions-item>
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
const certificationList = ref([])
const dialogVisible = ref(false)
const currentCertification = ref(null)

const searchForm = reactive({
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
    approved: 'success',
    rejected: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待审核',
    approved: '已通过',
    rejected: '已拒绝'
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

const fetchCertificationList = async () => {
  loading.value = true
  try {
    const response = await api.tutorCertification.getAllCertifications({
      page: pagination.page,
      size: pagination.size,
      status: searchForm.status
    })
    if (response.success) {
      certificationList.value = response.data || []
      pagination.total = response.data?.length || 0
    } else {
      ElMessage.error(response.message || '获取认证列表失败')
    }
  } catch (error) {
    ElMessage.error('获取认证列表失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchCertificationList()
}

const handleReset = () => {
  searchForm.status = ''
  pagination.page = 1
  fetchCertificationList()
}

const handleView = (row) => {
  currentCertification.value = row
  dialogVisible.value = true
}

const handleApprove = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要通过用户 ${row.realName} 的认证申请吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'success'
      }
    )

    const response = await api.tutorCertification.updateCertificationStatus(row.id, 'approved')
    if (response.success) {
      ElMessage.success('认证已通过')
      fetchCertificationList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

const handleReject = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要拒绝用户 ${row.realName} 的认证申请吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.tutorCertification.updateCertificationStatus(row.id, 'rejected')
    if (response.success) {
      ElMessage.success('认证已拒绝')
      fetchCertificationList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

const handleRevoke = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要吊销用户 ${row.realName} 的认证吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.tutorCertification.updateCertificationStatus(row.id, 'rejected')
    if (response.success) {
      ElMessage.success('认证已吊销')
      fetchCertificationList()
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
  fetchCertificationList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchCertificationList()
}

onMounted(() => {
  fetchCertificationList()
})
</script>

<style scoped>
.certification-management {
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
