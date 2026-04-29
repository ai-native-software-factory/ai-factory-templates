<script setup lang="ts">
import { useRouter } from 'vue-router'
import { ElButton } from 'element-plus'

const router = useRouter()

function goHome() {
  router.push('/')
}

function goBack() {
  router.back()
}
</script>

<template>
  <div class="not-found-page">
    <div class="not-found-container">
      <div class="not-found-content">
        <h1 class="error-code">404</h1>
        <h2 class="error-title">Page Not Found</h2>
        <p class="error-description">
          Sorry, the page you are looking for does not exist or has been moved.
        </p>
        <div class="error-actions">
          <el-button type="primary" @click="goHome">Go Home</el-button>
          <el-button @click="goBack">Go Back</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.not-found-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: $background-base;

  .not-found-container {
    text-align: center;
    padding: 40px;

    .not-found-content {
      .error-code {
        font-size: 120px;
        font-weight: 700;
        color: $primary-color;
        line-height: 1;
        margin-bottom: 16px;
      }

      .error-title {
        font-size: 32px;
        font-weight: 600;
        color: $text-primary;
        margin-bottom: 12px;
      }

      .error-description {
        font-size: $font-size-base;
        color: $text-secondary;
        margin-bottom: 32px;
        max-width: 400px;
        margin-left: auto;
        margin-right: auto;
      }

      .error-actions {
        display: flex;
        gap: 12px;
        justify-content: center;
      }
    }
  }
}
</style>
