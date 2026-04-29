export interface User {
  id: number
  username: string
  email: string
  avatar?: string
  roles?: string[]
  createdAt?: string
  updatedAt?: string
}

export interface LoginCredentials {
  username: string
  password: string
}

export interface PaginationParams {
  page: number
  pageSize: number
  total?: number
}

export interface PaginatedResponse<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export interface ApiResponse<T = unknown> {
  code: number
  message: string
  data: T
}

export interface CommonIdName {
  id: number
  name: string
}

export type Recordable<T = unknown> = Record<string, T>
