<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { ElCard, ElWelcome } from 'element-plus'

const authStore = useAuthStore()
const user = authStore.user

const stats = ref([
  { label: 'Total Users', value: '1,234', icon: 'user', color: '#409eff' },
  { label: 'Total Orders', value: '5,678', icon: 'shopping', color: '#67c23a' },
  { label: 'Total Revenue', value: '$98,765', icon: 'money', color: '#e6a23c' },
  { label: 'Total Views', value: '345,678', icon: 'view', color: '#f56c6c' },
])

onMounted(() => {
  // Fetch dashboard data
})
</script>

<template>
  <div class="home-page">
    <div class="page-header">
      <h1 class="page-title">Dashboard</h1>
      <p class="welcome-text">Welcome back, {{ user?.username || 'User' }}</p>
    </div>

    <div class="stats-grid">
      <el-card v-for="stat in stats" :key="stat.label" class="stat-card">
        <div class="stat-content">
          <div class="stat-info">
            <span class="stat-label">{{ stat.label }}</span>
            <span class="stat-value">{{ stat.value }}</span>
          </div>
        </div>
      </el-card>
    </div>

    <div class="charts-grid">
      <el-card class="chart-card">
        <template #header>
          <span>Recent Activity</span>
        </template>
        <div class="chart-placeholder">
          <p>Chart content goes here</p>
        </div>
      </el-card>
      <el-card class="chart-card">
        <template #header>
          <span>Statistics</span>
        </template>
        <div class="chart-placeholder">
          <p>Statistics content goes here</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.home-page {
  .page-header {
    margin-bottom: 24px;

    .page-title {
      font-size: 24px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 8px;
    }

    .welcome-text {
      color: $text-secondary;
      font-size: $font-size-base;
    }
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 20px;
    margin-bottom: 20px;

    .stat-card {
      .stat-content {
        display: flex;
        align-items: center;
        gap: 16px;

        .stat-info {
          display: flex;
          flex-direction: column;
          gap: 4px;

          .stat-label {
            font-size: $font-size-small;
            color: $text-secondary;
          }

          .stat-value {
            font-size: 24px;
            font-weight: 600;
            color: $text-primary;
          }
        }
      }
    }
  }

  .charts-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;

    @media (max-width: 992px) {
      grid-template-columns: 1fr;
    }

    .chart-card {
      .chart-placeholder {
        height: 300px;
        @include flex-center;
        color: $text-placeholder;
      }
    }
  }
}
</style>
