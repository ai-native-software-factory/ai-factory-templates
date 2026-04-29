import { request } from '@/utils/request'
import type { User } from '@/types/common'

export interface LoginData {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  user: User
}

export interface UserResponse {
  id: number
  username: string
  email: string
  avatar?: string
  roles?: string[]
}

export const authApi = {
  login(data: LoginData) {
    return request<LoginResponse>({
      url: '/auth/login',
      method: 'POST',
      data,
    })
  },

  logout() {
    return request<void>({
      url: '/auth/logout',
      method: 'POST',
    })
  },

  getUserInfo() {
    return request<UserResponse>({
      url: '/auth/user',
      method: 'GET',
    })
  },
}
