<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAppStore } from '@/stores/app'
import { ElMenu, ElMenuItem, ElSubMenu, ElIcon } from 'element-plus'
import {
  Home,
  User,
  Setting,
  Document,
  List,
  Table,
  Chart,
  Folder,
} from '@element-plus/icons-vue'

interface MenuItem {
  index: string
  title: string
  icon: string
  children?: MenuItem[]
}

const router = useRouter()
const route = useRoute()
const appStore = useAppStore()

const menuItems: MenuItem[] = [
  { index: '/', title: 'Home', icon: 'Home' },
  { index: '/users', title: 'Users', icon: 'User' },
  { index: '/content', title: 'Content', icon: 'Document' },
  { index: '/list', title: 'List', icon: 'List' },
  { index: '/table', title: 'Table', icon: 'Table' },
  { index: '/chart', title: 'Chart', icon: 'Chart' },
  {
    index: '/settings',
    title: 'Settings',
    icon: 'Setting',
    children: [
      { index: '/settings/profile', title: 'Profile', icon: 'User' },
      { index: '/settings/system', title: 'System', icon: 'Setting' },
    ],
  },
]

const activeIndex = computed(() => route.path)

function handleSelect(index: string) {
  router.push(index)
}

function getIcon(iconName: string) {
  const icons: Record<string, unknown> = {
    Home,
    User,
    Setting,
    Document,
    List,
    Table,
    Chart,
    Folder,
  }
  return icons[iconName] || Setting
}
</script>

<template>
  <aside class="common-sidebar" :class="{ collapsed: appStore.sidebarCollapsed }">
    <div class="sidebar-header">
      <h1 v-if="!appStore.sidebarCollapsed" class="logo-title">Vue Admin</h1>
      <span v-else class="logo-icon">V</span>
    </div>
    <el-menu
      :default-active="activeIndex"
      :collapse="appStore.sidebarCollapsed"
      :collapse-transition="false"
      class="sidebar-menu"
      @select="handleSelect"
    >
      <template v-for="item in menuItems" :key="item.index">
        <el-sub-menu v-if="item.children" :index="item.index">
          <template #title>
            <el-icon><component :is="getIcon(item.icon)" /></el-icon>
            <span>{{ item.title }}</span>
          </template>
          <el-menu-item
            v-for="child in item.children"
            :key="child.index"
            :index="child.index"
          >
            {{ child.title }}
          </el-menu-item>
        </el-sub-menu>
        <el-menu-item v-else :index="item.index">
          <el-icon><component :is="getIcon(item.icon)" /></el-icon>
          <span>{{ item.title }}</span>
        </el-menu-item>
      </template>
    </el-menu>
  </aside>
</template>

<style lang="scss" scoped>
.common-sidebar {
  width: $sidebar-width;
  height: 100vh;
  background: $sidebar-bg-color;
  transition: width 0.3s;
  overflow: hidden;

  &.collapsed {
    width: $sidebar-collapsed-width;
  }

  .sidebar-header {
    height: $header-height;
    @include flex-center;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);

    .logo-title {
      font-size: $font-size-extra-large;
      font-weight: $font-weight-bold;
      color: #ffffff;
      white-space: nowrap;
    }

    .logo-icon {
      font-size: 24px;
      font-weight: $font-weight-bold;
      color: #ffffff;
    }
  }

  .sidebar-menu {
    border-right: none;
    background: transparent;

    :deep(.el-menu-item),
    :deep(.el-sub-menu__title) {
      color: $sidebar-text-color;

      &:hover {
        background: rgba(255, 255, 255, 0.05) !important;
      }
    }

    :deep(.el-menu-item.is-active) {
      color: $sidebar-active-text-color !important;
      background: rgba(64, 158, 255, 0.1) !important;
    }

    :deep(.el-sub-menu .el-menu-item) {
      padding-left: 50px !important;
    }
  }
}
</style>
