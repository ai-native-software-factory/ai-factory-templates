<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { ElDropdown, ElDropdownMenu, ElDropdownItem, ElAvatar, ElIcon } from 'element-plus'
import { User, Setting, SwitchButton, Fold, Expand } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()

const username = computed(() => authStore.user?.username || 'User')
const avatar = computed(() => authStore.user?.avatar || '')

function handleCommand(command: string) {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'settings':
      router.push('/settings')
      break
    case 'logout':
      authStore.logout()
      router.push('/login')
      break
  }
}
</script>

<template>
  <header class="common-header">
    <div class="header-left">
      <el-icon class="collapse-btn" @click="appStore.toggleSidebar">
        <Fold v-if="!appStore.sidebarCollapsed" />
        <Expand v-else />
      </el-icon>
    </div>
    <div class="header-right">
      <el-dropdown @command="handleCommand" trigger="click">
        <div class="user-info">
          <el-avatar v-if="avatar" :size="32" :src="avatar" />
          <el-avatar v-else :size="32">
            <el-icon><User /></el-icon>
          </el-avatar>
          <span class="username">{{ username }}</span>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="profile">
              <el-icon><User /></el-icon>
              Profile
            </el-dropdown-item>
            <el-dropdown-item command="settings">
              <el-icon><Setting /></el-icon>
              Settings
            </el-dropdown-item>
            <el-dropdown-item command="logout" divided>
              <el-icon><SwitchButton /></el-icon>
              Logout
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </header>
</template>

<style lang="scss" scoped>
.common-header {
  @include flex-between;
  height: $header-height;
  padding: 0 20px;
  background: $header-bg-color;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);

  .header-left {
    @include flex-start;
    gap: 12px;

    .collapse-btn {
      font-size: 20px;
      cursor: pointer;
      color: $text-regular;
      transition: $transition-base;

      &:hover {
        color: $primary-color;
      }
    }
  }

  .header-right {
    .user-info {
      @include flex-center;
      gap: 8px;
      cursor: pointer;
      padding: 4px 8px;
      border-radius: $border-radius-base;
      transition: $transition-base;

      &:hover {
        background: $background-base;
      }

      .username {
        font-size: $font-size-base;
        color: $text-primary;
      }
    }
  }
}
</style>
