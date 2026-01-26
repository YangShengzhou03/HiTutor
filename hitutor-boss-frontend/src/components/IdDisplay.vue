<template>
  <div class="id-display">
    <el-tooltip content="点击复制" placement="top">
      <span class="id-text" @click="copyId">{{ displayId }}</span>
    </el-tooltip>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  id: {
    type: String,
    required: true
  }
})

const displayId = computed(() => {
  if (!props.id) return '-'
  if (props.id.length > 8) {
    return props.id.substring(0, 8) + '...'
  }
  return props.id
})

const copyId = () => {
  if (props.id) {
    navigator.clipboard.writeText(props.id).then(() => {
      ElMessage.success('ID已复制到剪贴板')
    }).catch(() => {
      ElMessage.error('复制失败')
    })
  }
}
</script>

<style scoped>
.id-display {
  display: inline-block;
}

.id-text {
  cursor: pointer;
  color: #409eff;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  user-select: none;
}

.id-text:hover {
  text-decoration: underline;
}
</style>
