<template>
  <div class="review-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>评价管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="评分">
          <el-select v-model="searchForm.rating" placeholder="全部评分" clearable>
            <el-option label="全部" value="" />
            <el-option label="5星" :value="5" />
            <el-option label="4星" :value="4" />
            <el-option label="3星" :value="3" />
            <el-option label="2星" :value="2" />
            <el-option label="1星" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="reviewList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="评价ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="orderId" label="预约ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.orderId" />
          </template>
        </el-table-column>
        <el-table-column prop="reviewerId" label="评价人ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.reviewerId" />
          </template>
        </el-table-column>
        <el-table-column prop="reviewedId" label="被评价人ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.reviewedId" />
          </template>
        </el-table-column>
        <el-table-column prop="rating" label="评分" width="120">
          <template #default="{ row }">
            <el-rate v-model="row.rating" disabled show-score text-color="#ff9900" />
          </template>
        </el-table-column>
        <el-table-column prop="comment" label="评价内容" width="300" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="100">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
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

    <el-dialog v-model="dialogVisible" title="评价详情" width="700px">
      <el-descriptions v-if="currentReview" :column="2" border>
        <el-descriptions-item label="评价ID">{{ currentReview.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="预约ID">{{ currentReview.orderId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="评价人ID">{{ currentReview.reviewerId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="被评价人ID">{{ currentReview.reviewedId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="评分" :span="2">
          <el-rate v-model="currentReview.rating" disabled show-score text-color="#ff9900" />
        </el-descriptions-item>
        <el-descriptions-item label="评价内容" :span="2">{{ currentReview.comment || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间" :span="2">{{ currentReview.createTime || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import IdDisplay from '@/components/IdDisplay.vue'
import api from '@/services/api'

const loading = ref(false)
const reviewList = ref([])
const dialogVisible = ref(false)
const currentReview = ref(null)

const searchForm = reactive({
  rating: null
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const fetchReviewList = async () => {
  loading.value = true
  try {
    const response = await api.review.getReviewsByUserId('admin')
    if (response.success) {
      reviewList.value = response.data || []
      pagination.total = response.data?.length || 0
    } else {
      ElMessage.error(response.message || '获取评价列表失败')
    }
  } catch (error) {
    ElMessage.error('获取评价列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchReviewList()
}

const handleReset = () => {
  searchForm.rating = null
  pagination.page = 1
  fetchReviewList()
}

const handleView = (row) => {
  currentReview.value = row
  dialogVisible.value = true
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
  fetchReviewList()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  fetchReviewList()
}

onMounted(() => {
  fetchReviewList()
})
</script>

<style scoped>
.review-management {
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
