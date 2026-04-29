<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { ElTable, ElTableColumn, ElPagination, ElButton, ElCheckbox } from 'element-plus'
import type { TableColumnCtx } from 'element-plus'

export interface TableColumn {
  prop?: string
  label?: string
  width?: string | number
  minWidth?: string | number
  align?: 'left' | 'center' | 'right'
  fixed?: 'left' | 'right' | true
  sortable?: boolean
  formatter?: (row: unknown, column: TableColumnCtx<unknown>, cellValue: unknown, index: number) => string
  slots?: {
    default?: string
    header?: string
  }
}

export interface TableProps {
  data: unknown[]
  columns: TableColumn[]
  loading?: boolean
  pagination?: boolean
  page?: number
  pageSize?: number
  total?: number
  selectable?: boolean
  rowKey?: string
}

const props = withDefaults(defineProps<TableProps>(), {
  loading: false,
  pagination: true,
  page: 1,
  pageSize: 10,
  total: 0,
  selectable: false,
  rowKey: 'id',
})

const emit = defineEmits<{
  (e: 'page-change', page: number, pageSize: number): void
  (e: 'selection-change', rows: unknown[]): void
}>()

const currentPage = ref(props.page)
const currentPageSize = ref(props.pageSize)

const hasSelection = computed(() => props.selectable)

function handlePageChange(page: number) {
  currentPage.value = page
  emit('page-change', page, currentPageSize.value)
}

function handleSizeChange(size: number) {
  currentPageSize.value = size
  emit('page-change', currentPage.value, size)
}

function handleSelectionChange(selection: unknown[]) {
  emit('selection-change', selection)
}

watch(
  () => [props.page, props.pageSize],
  ([newPage, newSize]) => {
    currentPage.value = newPage as number
    currentPageSize.value = newSize as number
  }
)
</script>

<template>
  <div class="common-table">
    <el-table
      :data="data"
      :loading="loading"
      :row-key="rowKey"
      :header-cell-style="{ background: '#f5f7fa', color: '#303133' }"
      style="width: 100%"
      @selection-change="handleSelectionChange"
    >
      <el-table-column v-if="selectable" type="selection" width="55" fixed="left" />
      <el-table-column
        v-for="column in columns"
        :key="column.prop"
        :prop="column.prop"
        :label="column.label"
        :width="column.width"
        :min-width="column.minWidth"
        :align="column.align || 'left'"
        :fixed="column.fixed"
        :sortable="column.sortable"
        :formatter="column.formatter"
      >
        <template v-if="column.slots?.default" #default="scope">
          <slot :name="column.prop" :row="scope.row" :$index="scope.$index" />
        </template>
        <template v-if="column.slots?.header" #header="scope">
          <slot :name="`${column.prop}-header`" :row="scope.row" />
        </template>
      </el-table-column>
      <el-table-column v-if="$slots.action" label="Actions" width="180" fixed="right" align="center">
        <template #default="scope">
          <slot name="action" :row="scope.row" :$index="scope.$index" />
        </template>
      </el-table-column>
    </el-table>

    <div v-if="pagination" class="table-pagination">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="currentPageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="handlePageChange"
        @size-change="handleSizeChange"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.common-table {
  .table-pagination {
    @include flex-end;
    margin-top: 16px;
    padding: 16px 0;
  }
}
</style>
