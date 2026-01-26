<template>
  <div class="admin-dashboard">
    <el-card class="dashboard-card">
      <template #header>
        <div class="card-header">
          <span>数据概览</span>
          <el-button link @click="refreshData" :loading="loading">
            <el-icon>
              <Refresh />
            </el-icon>
            刷新
          </el-button>
        </div>
      </template>

      <div class="dashboard-content">
        <el-row :gutter="20" class="stats-row">
          <el-col :span="6">
            <div class="stat-card primary">
              <div class="stat-item">
                <div class="stat-icon">
                  <el-icon>
                    <User />
                  </el-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">总用户数</div>
                  <div class="stat-value">{{ stats.totalUsers }}</div>
                </div>
              </div>
            </div>
          </el-col>

          <el-col :span="6">
            <div class="stat-card danger">
              <div class="stat-item">
                <div class="stat-icon">
                  <el-icon>
                    <Warning />
                  </el-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">待处理投诉</div>
                  <div class="stat-value">{{ stats.pendingComplaints }}</div>
                </div>
              </div>
            </div>
          </el-col>

          <el-col :span="6">
            <div class="stat-card success">
              <div class="stat-item">
                <div class="stat-icon">
                  <el-icon>
                    <Document />
                  </el-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">学生需求</div>
                  <div class="stat-value">{{ stats.studentRequests }}</div>
                </div>
              </div>
            </div>
          </el-col>

          <el-col :span="6">
            <div class="stat-card warning">
              <div class="stat-item">
                <div class="stat-icon">
                  <el-icon>
                    <List />
                  </el-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">家教信息</div>
                  <div class="stat-value">{{ stats.tutorProfiles }}</div>
                </div>
              </div>
            </div>
          </el-col>
        </el-row>

        <el-row :gutter="20" class="charts-row">
          <el-col :span="12">
            <el-card class="chart-card">
              <template #header>
                <div class="chart-header">
                  <span>用户角色分布</span>
                </div>
              </template>
              <div class="chart-container">
                <div v-if="userRoleDistribution.length === 0" class="no-data">
                  <el-empty description="暂无数据" :image-size="80" />
                </div>
                <div v-else class="chart-content">
                  <v-chart :option="userRoleChartOption" style="height: 300px;" />
                </div>
              </div>
            </el-card>
          </el-col>

          <el-col :span="12">
            <el-card class="chart-card">
              <template #header>
                <div class="chart-header">
                  <span>科目分布</span>
                </div>
              </template>
              <div class="chart-container">
                <div v-if="subjectDistribution.length === 0" class="no-data">
                  <el-empty description="暂无数据" :image-size="80" />
                </div>
                <div v-else class="chart-content">
                  <v-chart :option="subjectChartOption" style="height: 300px;" />
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import {
  Refresh, User, Warning, Document, List
} from '@element-plus/icons-vue'
import api from '../../services/api'

use([
  CanvasRenderer,
  PieChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent
])

const stats = ref({
  totalUsers: 0,
  pendingComplaints: 0,
  studentRequests: 0,
  tutorProfiles: 0
})

const loading = ref(false)

const userRoleDistribution = ref([
  { name: '家教老师', value: 0 },
  { name: '学生', value: 0 },
  { name: '管理员', value: 0 }
])

const subjectDistribution = ref([])

const userRoleChartOption = computed(() => {
  return {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '用户角色',
        type: 'pie',
        radius: '50%',
        data: userRoleDistribution.value,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
})

const subjectChartOption = computed(() => {
  return {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '科目',
        type: 'pie',
        radius: '50%',
        data: subjectDistribution.value,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
})

const refreshData = async () => {
  await loadDashboardData()
}

const loadDashboardData = async () => {
  try {
    loading.value = true
    const response = await api.admin.getDashboardStats()

    if (response.success) {
      const data = response.data
      stats.value = {
        totalUsers: data.totalUsers || 0,
        pendingComplaints: data.pendingComplaints || 0,
        studentRequests: data.studentRequests || 0,
        tutorProfiles: data.tutorProfiles || 0
      }

      updateUserRoleDistribution(data)
      await loadSubjectDistribution()
    } else {
      ElMessage.error(response.message || '获取统计数据失败')
    }
  } catch (error) {
    ElMessage.error('获取统计数据失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

const loadSubjectDistribution = async () => {
  try {
    const response = await api.admin.getSubjectDistribution()
    if (response.success) {
      updateSubjectDistribution(response.data)
    }
  } catch (error) {
    console.error('获取科目分布失败', error)
  }
}

const updateUserRoleDistribution = (data) => {
  userRoleDistribution.value = [
    { name: '家教老师', value: data.activeTutors || 0 },
    { name: '学生', value: data.activeStudents || 0 },
    { name: '管理员', value: 1 }
  ]
}

const updateSubjectDistribution = (data) => {
  if (data && Array.isArray(data)) {
    subjectDistribution.value = data
  } else {
    subjectDistribution.value = []
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
.admin-dashboard {
  padding: 0;
  background-color: #f5f7fa;
}

.dashboard-card {
  margin-bottom: 0px;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}

.dashboard-card :deep(.el-card__body) {
  padding: 12px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  font-size: 16px;
  color: #303133;
}

.stat-card {
  height: 100%;
  border: 1px solid #ebeef5;
  border-radius: 2px;
  background-color: #fff;
  padding: 12px;
}

.stat-card:hover {
  border-color: #c6e2ff;
}

.stat-card.primary {
  border-left: 4px solid #409eff;
}

.stat-card.success {
  border-left: 4px solid #67c23a;
}

.stat-card.warning {
  border-left: 4px solid #e6a23c;
}

.stat-card.info {
  border-left: 4px solid #909399;
}

.stat-card.danger {
  border-left: 4px solid #f56c6c;
}

.stat-item {
  display: flex;
  align-items: center;
}

.stat-icon {
  margin-right: 12px;
  width: 40px;
  height: 40px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #409eff;
}

.stat-icon .el-icon {
  color: #fff;
  font-size: 24px;
}

.stat-content {
  flex: 1;
}

.stat-title {
  font-size: 13px;
  color: #909399;
  margin-bottom: 6px;
  font-weight: 500;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  line-height: 1.2;
}

.chart-card {
  margin-top: 16px;
  border-radius: 4px;
  border: 1px solid #ebeef5;
  min-height: 350px;
  display: flex;
  flex-direction: column;
}

.chart-card:hover {
  border-color: #c6e2ff;
}

.chart-header {
  font-weight: 600;
  font-size: 16px;
  color: #303133;
  flex-shrink: 0;
}

.chart-container {
  padding: 12px 0;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-content {
  width: 100%;
  height: 100%;
}

.no-data {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stats-row {
  margin-bottom: 20px;
}

.charts-row {
  margin-top: 16px;
}

@media (max-width: 1200px) {
  .stats-row .el-col {
    margin-bottom: 20px;
  }

  .charts-row .el-col {
    margin-bottom: 20px;
  }
}

@media (max-width: 768px) {
  .stats-row .el-col {
    width: 100%;
  }

  .charts-row .el-col {
    width: 100%;
  }
}
</style>
