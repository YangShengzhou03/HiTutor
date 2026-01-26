<template>
  <div class="blacklist-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>黑名单管理</span>
        </div>
      </template>

      <el-table :data="blacklist" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="记录ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="200">
          <template #default="{ row }">
            <IdDisplay :id="row.userId" />
          </template>
        </el-table-column>
        <el-table-column prop="blockedUserId" label="被拉黑用户ID" width="200">
          <template #default="{ row }">
            <IdDisplay :id="row.blockedUserId" />
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import IdDisplay from '@/components/IdDisplay.vue'
import api from '@/services/api'

const loading = ref(false)
const blacklist = ref([])

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const fetchBlacklist = async () => {
  loading.value = true
  try {
    const response = await api.blacklist.getAllBlacklist({
      page: pagination.page,
      size: pagination.size
    })
    if (response.success) {
      const { content, total } = response.data
      blacklist.value = content || []
      pagination.total = total || 0
    } else {
      ElMessage.error(response.message || '获取黑名单失败')
    }
  } catch (error) {
    ElMessage.error('获取黑名单失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除黑名单记录 #${row.id} 吗？此操作不可恢复。`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.blacklist.deleteBlacklistEntry(row.id)
    if (response.success) {
      ElMessage.success('删除成功')
      fetchBlacklist()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
      console.error(error)
    }
  }
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

const handleSizeChange = (size) => {
  pagination.size = size
  fetchBlacklist()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchBlacklist()
}

onMounted(() => {
  fetchBlacklist()
})
</script>

<style scoped>
.blacklist-management {
  padding: 0;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
