<template>
  <div class="notification-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>通知管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="通知类型">
          <el-select v-model="searchForm.type" placeholder="全部类型" clearable>
            <el-option label="全部" value="" />
            <el-option label="系统通知" value="system" />
            <el-option label="活动通知" value="activity" />
            <el-option label="报名通知" value="application" />
            <el-option label="报名通过" value="application_accepted" />
            <el-option label="报名拒绝" value="application_rejected" />
            <el-option label="预约确认" value="application_confirmed" />
            <el-option label="投诉通知" value="complaint" />
            <el-option label="公告" value="announcement" />
            <el-option label="消息通知" value="message" />
            <el-option label="评价通知" value="review" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.isRead" placeholder="全部状态" clearable>
            <el-option label="全部" value="" />
            <el-option label="未读" :value="0" />
            <el-option label="已读" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="showSendDialog = true">发送通知</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="notifications" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="通知ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.id" />
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="120">
          <template #default="{ row }">
            <IdDisplay :id="row.userId" />
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" width="200" show-overflow-tooltip />
        <el-table-column prop="content" label="内容" show-overflow-tooltip />
        <el-table-column prop="type" label="类型" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.type === 'system'" type="info">系统通知</el-tag>
            <el-tag v-else-if="row.type === 'activity'" type="success">活动通知</el-tag>
            <el-tag v-else-if="row.type === 'application'" type="warning">报名通知</el-tag>
            <el-tag v-else-if="row.type === 'application_accepted'" type="success">报名通过</el-tag>
            <el-tag v-else-if="row.type === 'application_rejected'" type="danger">报名拒绝</el-tag>
            <el-tag v-else-if="row.type === 'application_confirmed'" type="success">预约确认</el-tag>
            <el-tag v-else-if="row.type === 'complaint'" type="danger">投诉通知</el-tag>
            <el-tag v-else-if="row.type === 'announcement'" type="warning">公告</el-tag>
            <el-tag v-else-if="row.type === 'message'" type="primary">消息通知</el-tag>
            <el-tag v-else-if="row.type === 'review'" type="success">评价通知</el-tag>
            <el-tag v-else>{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="isRead" label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.isRead === 0" type="danger">未读</el-tag>
            <el-tag v-else type="success">已读</el-tag>
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
        <template #empty>
          <el-empty description="暂无通知数据" :image-size="80" />
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

    <el-dialog v-model="dialogVisible" title="通知详情" width="700px">
      <el-descriptions v-if="currentNotification" :column="2" border>
        <el-descriptions-item label="通知ID">{{ currentNotification.id || '-' }}</el-descriptions-item>
        <el-descriptions-item label="用户ID">{{ currentNotification.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="标题">{{ currentNotification.title || '-' }}</el-descriptions-item>
        <el-descriptions-item label="类型">
          <el-tag v-if="currentNotification.type === 'system'" type="info">系统通知</el-tag>
          <el-tag v-else-if="currentNotification.type === 'activity'" type="success">活动通知</el-tag>
          <el-tag v-else-if="currentNotification.type === 'application'" type="warning">报名通知</el-tag>
          <el-tag v-else-if="currentNotification.type === 'application_accepted'" type="success">报名通过</el-tag>
          <el-tag v-else-if="currentNotification.type === 'application_rejected'" type="danger">报名拒绝</el-tag>
          <el-tag v-else-if="currentNotification.type === 'application_confirmed'" type="success">预约确认</el-tag>
          <el-tag v-else-if="currentNotification.type === 'complaint'" type="danger">投诉通知</el-tag>
          <el-tag v-else-if="currentNotification.type === 'announcement'" type="warning">公告</el-tag>
          <el-tag v-else-if="currentNotification.type === 'message'" type="primary">消息通知</el-tag>
          <el-tag v-else-if="currentNotification.type === 'review'" type="success">评价通知</el-tag>
          <el-tag v-else>{{ currentNotification.type }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag v-if="currentNotification.isRead === 0" type="danger">未读</el-tag>
          <el-tag v-else type="success">已读</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="内容" :span="2">
          {{ currentNotification.content || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ formatDateTime(currentNotification.createTime) }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <el-dialog
      v-model="showSendDialog"
      title="发送通知"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="sendForm" :rules="rules" ref="sendFormRef" label-width="100px">
        <el-form-item label="通知类型" prop="type">
          <el-select v-model="sendForm.type" placeholder="请选择通知类型" style="width: 100%">
            <el-option label="系统通知" value="system"></el-option>
            <el-option label="活动通知" value="activity"></el-option>
            <el-option label="公告" value="announcement"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="接收对象" prop="targetType">
          <el-radio-group v-model="sendForm.targetType">
            <el-radio label="all">全员发送</el-radio>
            <el-radio label="user">指定用户</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item 
          v-if="sendForm.targetType === 'user'" 
          label="用户ID" 
          prop="userId"
        >
          <el-input 
            v-model="sendForm.userId" 
            placeholder="请输入用户ID"
            clearable
          ></el-input>
        </el-form-item>

        <el-form-item label="通知标题" prop="title">
          <el-input 
            v-model="sendForm.title" 
            placeholder="请输入通知标题"
            maxlength="100"
            show-word-limit
          ></el-input>
        </el-form-item>

        <el-form-item label="通知内容" prop="content">
          <el-input 
            v-model="sendForm.content" 
            type="textarea"
            :rows="4"
            placeholder="请输入通知内容"
            maxlength="500"
            show-word-limit
          ></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showSendDialog = false">取消</el-button>
        <el-button type="primary" @click="sendNotification" :loading="sending">
          发送通知
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import IdDisplay from '@/components/IdDisplay.vue'
import Server from '@/utils/Server'

const sendFormRef = ref(null)
const sending = ref(false)
const loading = ref(false)
const notifications = ref([])
const dialogVisible = ref(false)
const currentNotification = ref(null)
const isLoading = ref(false)

const searchForm = reactive({
  type: '',
  isRead: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const sendForm = reactive({
  type: 'system',
  targetType: 'all',
  userId: '',
  title: '',
  content: ''
})

const rules = {
  title: [
    { required: true, message: '请输入通知标题', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入通知内容', trigger: 'blur' }
  ]
}

const showSendDialog = ref(false)

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

const loadNotifications = async () => {
  if (isLoading.value) {
    return
  }
  
  isLoading.value = true
  loading.value = true
  try {
    const response = await Server.get('/api/notifications/admin/list', {
      page: pagination.page,
      size: pagination.size,
      type: searchForm.type,
      isRead: searchForm.isRead
    })
    if (response.success) {
      notifications.value = response.data?.content || []
      pagination.total = response.data?.totalElements || 0
    } else {
      ElMessage.error(response.message || '获取通知列表失败')
    }
  } catch (error) {
    ElMessage.error('获取通知列表失败')
  } finally {
    loading.value = false
    isLoading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadNotifications()
}

const handleReset = () => {
  searchForm.type = ''
  searchForm.isRead = ''
  pagination.page = 1
  loadNotifications()
}

const sendNotification = async () => {
  if (!sendFormRef.value) return
  
  if (sending.value) {
    ElMessage.warning('正在发送中，请稍候...')
    return
  }

  await sendFormRef.value.validate(async (valid) => {
    if (!valid) return

    if (sendForm.targetType === 'user' && !sendForm.userId) {
      ElMessage.warning('请输入用户ID')
      return
    }

    sending.value = true
    try {
      const data = {
        type: sendForm.type,
        title: sendForm.title,
        content: sendForm.content
      }

      if (sendForm.targetType === 'user') {
        data.userId = sendForm.userId
      }

      const response = await Server.post('/api/notifications/admin/send', data)
      if (response.success) {
        ElMessage.success(response.message || '发送成功')
        resetForm()
        showSendDialog.value = false
        loadNotifications()
      } else {
        ElMessage.error(response.message || '发送失败')
      }
    } catch (error) {
      ElMessage.error('发送失败')
    } finally {
      sending.value = false
    }
  })
}

const resetForm = () => {
  if (sendFormRef.value) {
    sendFormRef.value.resetFields()
  }
  sendForm.type = 'system'
  sendForm.targetType = 'all'
  sendForm.userId = ''
  sendForm.title = ''
  sendForm.content = ''
}

const handleView = (row) => {
  currentNotification.value = row
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除通知 #${row.id} 吗？此操作不可恢复。`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await Server.delete(`/api/notifications/${row.id}`)
    if (response.status === 200) {
      ElMessage.success('删除成功')
      loadNotifications()
    } else {
      ElMessage.error('删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSizeChange = (size) => {
  pagination.size = size
  loadNotifications()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  loadNotifications()
}

onMounted(() => {
  loadNotifications()
})
</script>

<style scoped>
.notification-management {
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
