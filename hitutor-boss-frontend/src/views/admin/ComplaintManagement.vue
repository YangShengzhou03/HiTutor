<template>
  <div class="complaint-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>投诉管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="全部" value="" />
            <el-option label="待处理" value="pending" />
            <el-option label="处理中" value="processing" />
            <el-option label="已解决" value="resolved" />
            <el-option label="已拒绝" value="rejected" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="complaintList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="投诉ID" width="100" show-overflow-tooltip />
        <el-table-column prop="userId" label="投诉人ID" width="100" show-overflow-tooltip />
        <el-table-column prop="targetUserId" label="被投诉用户ID" width="120" show-overflow-tooltip />
        <el-table-column prop="targetUserName" label="被投诉用户" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.targetUserName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="categoryName" label="分类名称" min-width="100" show-overflow-tooltip />
        <el-table-column prop="typeText" label="投诉类型" min-width="120" show-overflow-tooltip />
        <el-table-column prop="description" label="投诉说明" min-width="150" show-overflow-tooltip />
        <el-table-column prop="contactPhone" label="联系电话" min-width="110" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button
              v-if="row.status === 'pending' || row.status === 'processing'"
              type="success"
              size="small"
              @click="handleResolve(row)"
            >
              解决
            </el-button>
            <el-button
              v-if="row.status === 'pending' || row.status === 'processing'"
              type="danger"
              size="small"
              @click="handleReject(row)"
            >
              拒绝
            </el-button>
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

    <el-dialog v-model="dialogVisible" title="投诉详情" width="700px">
      <el-descriptions v-if="currentComplaint" :column="2" border>
        <el-descriptions-item label="投诉ID">{{ currentComplaint.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="投诉人ID">{{ currentComplaint.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="投诉人">{{ currentComplaint.userName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="被投诉用户ID">{{ currentComplaint.targetUserId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="被投诉用户">{{ currentComplaint.targetUserName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="分类名称">{{ currentComplaint.categoryName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="投诉类型">{{ currentComplaint.typeText || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentComplaint.contactPhone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentComplaint.status)">
            {{ getStatusText(currentComplaint.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="投诉说明" :span="2">
          {{ currentComplaint.description || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentComplaint.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ currentComplaint.updateTime || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '@/services/api'

const loading = ref(false)
const complaintList = ref([])
const dialogVisible = ref(false)
const currentComplaint = ref(null)

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
    processing: 'primary',
    resolved: 'success',
    rejected: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待处理',
    processing: '处理中',
    resolved: '已解决',
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

const fetchComplaintList = async () => {
  loading.value = true
  try {
    const response = await api.complaint.getComplaints({
      page: pagination.page,
      size: pagination.size,
      status: searchForm.status
    })
    if (response.success) {
      complaintList.value = response.data || []
      pagination.total = response.data?.length || 0
    } else {
      ElMessage.error(response.message || '获取投诉列表失败')
    }
  } catch (error) {
    ElMessage.error('获取投诉列表失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchComplaintList()
}

const handleReset = () => {
  searchForm.status = ''
  pagination.page = 1
  fetchComplaintList()
}

const handleView = (row) => {
  currentComplaint.value = row
  dialogVisible.value = true
}

const handleResolve = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要将投诉 #${row.id} 标记为已解决吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'success'
      }
    )

    const response = await api.complaint.updateComplaintStatus(row.id, 'resolved')
    if (response.success) {
      ElMessage.success('投诉已解决')
      fetchComplaintList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
      console.error(error)
    }
  }
}

const handleReject = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要拒绝投诉 #${row.id} 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.complaint.updateComplaintStatus(row.id, 'rejected')
    if (response.success) {
      ElMessage.success('投诉已拒绝')
      fetchComplaintList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
      console.error(error)
    }
  }
}



const handleSizeChange = (size) => {
  pagination.size = size
  fetchComplaintList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchComplaintList()
}

onMounted(() => {
  fetchComplaintList()
})
</script>

<style scoped>
.complaint-management {
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
