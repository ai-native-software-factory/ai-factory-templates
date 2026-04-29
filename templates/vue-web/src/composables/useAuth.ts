import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'
import type { LoginCredentials } from '@/types/common'

export function useAuth() {
  const authStore = useAuthStore()
  const router = useRouter()

  const user = computed(() => authStore.user)
  const isAuthenticated = computed(() => authStore.isAuthenticated)
  const isAdmin = computed(() => authStore.user?.roles?.includes('admin'))

  async function login(credentials: LoginCredentials) {
    await authStore.login(credentials)
    const redirect = router.currentRoute.value.query.redirect as string
    router.push(redirect || '/')
  }

  function logout() {
    authStore.logout()
    router.push({ name: 'Login' })
  }

  function hasRole(role: string): boolean {
    return authStore.user?.roles?.includes(role) ?? false
  }

  return {
    user,
    isAuthenticated,
    isAdmin,
    login,
    logout,
    hasRole,
  }
}
