import { ref, computed } from 'vue'

export function useLoading(initialState = false) {
  const loading = ref(initialState)
  const error = ref<Error | null>(null)

  const isLoading = computed(() => loading.value)
  const hasError = computed(() => error.value !== null)

  async function withLoading<T>(fn: () => Promise<T>): Promise<T | undefined> {
    loading.value = true
    error.value = null
    try {
      const result = await fn()
      return result
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e))
      throw e
    } finally {
      loading.value = false
    }
  }

  function setLoading(state: boolean) {
    loading.value = state
  }

  function setError(e: Error | null) {
    error.value = e
  }

  function reset() {
    loading.value = false
    error.value = null
  }

  return {
    loading,
    error,
    isLoading,
    hasError,
    withLoading,
    setLoading,
    setError,
    reset,
  }
}
