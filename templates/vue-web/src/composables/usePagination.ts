import { ref, computed, watch } from 'vue'
import type { PageParams } from '@/types/api'

export interface UsePaginationOptions {
  page?: number
  pageSize?: number
  immediate?: boolean
  onChange?: (page: number, pageSize: number) => void
}

export function usePagination<T>(options: UsePaginationOptions = {}) {
  const { immediate = false, onChange } = options

  const page = ref(options.page ?? 1)
  const pageSize = ref(options.pageSize ?? 10)
  const total = ref(0)
  const list = ref<T[]>([]) as { value: T[] }

  const totalPages = computed(() => Math.ceil(total.value / pageSize.value))

  const hasNext = computed(() => page.value < totalPages.value)
  const hasPrev = computed(() => page.value > 1)

  const paginationInfo = computed(() => ({
    page: page.value,
    pageSize: pageSize.value,
    total: total.value,
    totalPages: totalPages.value,
    hasNext: hasNext.value,
    hasPrev: hasPrev.value,
  }))

  function setPage(newPage: number) {
    if (newPage < 1 || newPage > totalPages.value) return
    page.value = newPage
    onChange?.(page.value, pageSize.value)
  }

  function setPageSize(newSize: number) {
    pageSize.value = newSize
    page.value = 1
    onChange?.(page.value, pageSize.value)
  }

  function setTotal(newTotal: number) {
    total.value = newTotal
  }

  function setList(newList: T[]) {
    list.value = newList
  }

  function nextPage() {
    setPage(page.value + 1)
  }

  function prevPage() {
    setPage(page.value - 1)
  }

  function reset() {
    page.value = 1
    total.value = 0
    list.value = []
  }

  function getParams(): PageParams {
    return {
      page: page.value,
      pageSize: pageSize.value,
      total: total.value,
    }
  }

  watch(
    () => [page.value, pageSize.value],
    () => {
      if (immediate) {
        onChange?.(page.value, pageSize.value)
      }
    }
  )

  return {
    page,
    pageSize,
    total,
    list,
    totalPages,
    hasNext,
    hasPrev,
    paginationInfo,
    setPage,
    setPageSize,
    setTotal,
    setList,
    nextPage,
    prevPage,
    reset,
    getParams,
  }
}
