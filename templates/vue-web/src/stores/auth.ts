import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User, LoginCredentials } from '@/types/common'
import { request } from '@/utils/request'
import { setToken, removeToken, getToken } from '@/utils/storage'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(getToken())
  const user = ref<User | null>(null)

  const isAuthenticated = computed(() => !!token.value)

  async function login(credentials: LoginCredentials): Promise<void> {
    const response = await request<{ token: string; user: User }>({
      url: '/auth/login',
      method: 'POST',
      data: credentials,
    })
    token.value = response.token
    user.value = response.user
    setToken(response.token)
  }

  function logout(): void {
    token.value = null
    user.value = null
    removeToken()
  }

  async function fetchUser(): Promise<void> {
    if (!token.value) return
    const response = await request<User>({
      url: '/auth/user',
      method: 'GET',
    })
    user.value = response
  }

  return {
    token,
    user,
    isAuthenticated,
    login,
    logout,
    fetchUser,
  }
})
