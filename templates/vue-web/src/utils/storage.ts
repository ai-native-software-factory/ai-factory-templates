const TOKEN_KEY = 'auth_token'

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token)
}

export function removeToken(): void {
  localStorage.removeItem(TOKEN_KEY)
}

export function getItem<T>(key: string): T | null {
  const item = localStorage.getItem(key)
  if (!item) return null
  try {
    return JSON.parse(item) as T
  } catch {
    return item as unknown as T
  }
}

export function setItem(key: string, value: unknown): void {
  localStorage.setItem(key, JSON.stringify(value))
}

export function removeItem(key: string): void {
  localStorage.removeItem(key)
}

export function clear(): void {
  localStorage.clear()
}
