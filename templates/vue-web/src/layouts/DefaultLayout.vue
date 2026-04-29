<script setup lang="ts">
import { RouterView } from 'vue-router'
import CommonHeader from '@/components/CommonHeader.vue'
import CommonSidebar from '@/components/CommonSidebar.vue'
import CommonFooter from '@/components/CommonFooter.vue'
import { useAppStore } from '@/stores/app'

const appStore = useAppStore()
</script>

<template>
  <div class="default-layout" :class="{ collapsed: appStore.sidebarCollapsed }">
    <CommonSidebar />
    <div class="main-container">
      <CommonHeader />
      <main class="main-content">
        <RouterView />
      </main>
      <CommonFooter />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.default-layout {
  display: flex;
  width: 100vw;
  height: 100vh;
  overflow: hidden;

  .main-container {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    transition: margin-left 0.3s;

    .main-content {
      flex: 1;
      overflow-y: auto;
      background: $background-base;
      padding: 20px;
    }
  }

  &.collapsed {
    :deep(.common-sidebar) {
      width: $sidebar-collapsed-width;
    }
  }
}
</style>
