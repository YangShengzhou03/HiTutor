<template>
  <div class="subject-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>科目管理</span>
          <el-button type="primary" @click="handleAdd">添加科目</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="全部" value="" />
            <el-option label="启用" value="active" />
            <el-option label="禁用" value="inactive" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="subjectList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="科目ID" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.id ? (row.id.length > 4 ? row.id.substring(0, 4) + '...' : row.id) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="name" label="科目名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
              {{ row.status === 'active' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="180" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatDateTime(row.updateTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="180" show-overflow-tooltip>
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="科目名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入科目名称" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="启用" value="active" />
            <el-option label="禁用" value="inactive" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

import api from '@/services/api'

const loading = ref(false)
const subjectList = ref([])
const dialogVisible = ref(false)
const dialogTitle = computed(() => form.id ? '编辑科目' : '添加科目')
const formRef = ref(null)

const form = reactive({
  id: null,
  name: '',
  status: 'active'
})

const searchForm = reactive({
  status: ''
})

const rules = {
  name: [
    { required: true, message: '请输入科目名称', trigger: 'blur' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

const fetchSubjectList = async () => {
  loading.value = true
  try {
    const response = await api.subject.getAllSubjects()
    if (response.success) {
      let subjects = response.data || []
      if (searchForm.status) {
        subjects = subjects.filter(s => s.status === searchForm.status)
      }
      subjectList.value = subjects
    } else {
      ElMessage.error(response.message || '获取科目列表失败')
    }
  } catch (error) {
    ElMessage.error('获取科目列表失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  fetchSubjectList()
}

const handleReset = () => {
  searchForm.status = ''
  fetchSubjectList()
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

const handleAdd = () => {
  form.id = null
  form.name = ''
  form.status = 'active'
  dialogVisible.value = true
}

const handleEdit = (row) => {
  form.id = row.id
  form.name = row.name
  form.status = row.status
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        let response
        if (form.id) {
          response = await api.subject.updateSubject(form.id, form)
        } else {
          response = await api.subject.createSubject(form)
        }
        
        if (response.success) {
          ElMessage.success(form.id ? '更新成功' : '添加成功')
          dialogVisible.value = false
          fetchSubjectList()
        } else {
          ElMessage.error(response.message || '操作失败')
        }
      } catch (error) {
        ElMessage.error('操作失败')
        console.error(error)
      }
    }
  })
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除科目 "${row.name}" 吗？此操作不可恢复。`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await api.subject.deleteSubject(row.id)
    if (response.success) {
      ElMessage.success('删除成功')
      fetchSubjectList()
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

onMounted(() => {
  fetchSubjectList()
})
</script>

<style scoped>
.subject-management {
  padding: 0;
}

.search-form {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
