import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type AxiosResponse,
  type InternalAxiosRequestConfig,
} from 'axios'
import { ElMessage } from 'element-plus'
import { getToken, removeToken } from './storage'
import router from '@/router'

const instance: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
})

instance.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = getToken()
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    const { data, status } = response
    if (status === 200 || status === 201) {
      return data
    }
    ElMessage.error('Request failed')
    return Promise.reject(new Error('Request failed'))
  },
  (error) => {
    const { response } = error
    if (response) {
      const { status } = response
      switch (status) {
        case 401:
          ElMessage.error('Unauthorized, please login again')
          removeToken()
          router.push({ name: 'Login' })
          break
        case 403:
          ElMessage.error('Access denied')
          break
        case 404:
          ElMessage.error('Resource not found')
          break
        case 500:
          ElMessage.error('Server error')
          break
        default:
          ElMessage.error(error.message || 'Request error')
      }
    } else {
      ElMessage.error('Network error')
    }
    return Promise.reject(error)
  }
)

export interface RequestConfig extends AxiosRequestConfig {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
  data?: unknown
  params?: unknown
}

export function request<T>(config: RequestConfig): Promise<T> {
  return instance.request<unknown, T>(config as AxiosRequestConfig)
}

export { instance as axiosInstance }
