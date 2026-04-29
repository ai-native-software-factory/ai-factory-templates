import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAppStore = defineStore('app', () => {
  const sidebarCollapsed = ref(false)
  const loading = ref(false)
  const device = ref<'desktop' | 'mobile'>('desktop')

  function toggleSidebar(): void {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  function setSidebarCollapsed(collapsed: boolean): void {
    sidebarCollapsed.value = collapsed
  }

  function setLoading(isLoading: boolean): void {
    loading.value = isLoading
  }

  function setDevice(d: 'desktop' | 'mobile'): void {
    device.value = d
  }

  return {
    sidebarCollapsed,
    loading,
    device,
    toggleSidebar,
    setSidebarCollapsed,
    setLoading,
    setDevice,
  }
})
