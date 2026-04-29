export interface ApiResult<T = unknown> {
  code: number
  message: string
  data: T
  timestamp?: number
}

export interface PageResult<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export interface PageParams {
  page?: number
  pageSize?: number
  total?: number
}

export interface UploadResult {
  url: string
  filename: string
  size: number
  mimeType: string
}

export interface FileItem {
  id: string
  name: string
  url: string
  size: number
  mimeType: string
  createdAt?: string
}

declare module 'axios' {
  export interface AxiosRequestConfig {
    url: string
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'HEAD' | 'OPTIONS'
    data?: unknown
    params?: unknown
    headers?: Record<string, string>
    timeout?: number
  }
}
