<script setup lang="ts">
import { ref } from 'vue'
import { ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton, ElDatePicker } from 'element-plus'
import type { FormInstance } from 'element-plus'

export interface FormField {
  prop: string
  label?: string
  type: 'input' | 'select' | 'date' | 'textarea' | 'password'
  placeholder?: string
  options?: { label: string; value: unknown }[]
  disabled?: boolean
  cols?: number
}

export interface FormProps {
  fields: FormField[]
  model: Record<string, unknown>
  labelWidth?: string
  inline?: boolean
  loading?: boolean
}

const props = withDefaults(defineProps<FormProps>(), {
  labelWidth: '100px',
  inline: false,
  loading: false,
})

const emit = defineEmits<{
  (e: 'submit', model: Record<string, unknown>): void
  (e: 'reset'): void
}>()

const formRef = ref<FormInstance>()

async function validate(): Promise<boolean> {
  if (!formRef.value) return false
  try {
    await formRef.value.validate()
    return true
  } catch {
    return false
  }
}

function resetFields() {
  formRef.value?.resetFields()
}

function clearValidate() {
  formRef.value?.clearValidate()
}

function handleSubmit() {
  emit('submit', props.model)
}

function handleReset() {
  emit('reset')
}

defineExpose({
  validate,
  resetFields,
  clearValidate,
})
</script>

<template>
  <el-form
    ref="formRef"
    :model="model"
    :label-width="labelWidth"
    :inline="inline"
    class="common-form"
  >
    <el-form-item
      v-for="field in fields"
      :key="field.prop"
      :label="field.label"
      :prop="field.prop"
      :class="field.cols ? `col-${field.cols}` : ''"
    >
      <el-input
        v-if="field.type === 'input'"
        v-model="model[field.prop]"
        :placeholder="field.placeholder"
        :disabled="field.disabled"
      />
      <el-input
        v-else-if="field.type === 'textarea'"
        v-model="model[field.prop]"
        type="textarea"
        :placeholder="field.placeholder"
        :disabled="field.disabled"
      />
      <el-input
        v-else-if="field.type === 'password'"
        v-model="model[field.prop]"
        type="password"
        :placeholder="field.placeholder"
        :disabled="field.disabled"
      />
      <el-select
        v-else-if="field.type === 'select'"
        v-model="model[field.prop]"
        :placeholder="field.placeholder"
        :disabled="field.disabled"
      >
        <el-option
          v-for="option in field.options"
          :key="option.value"
          :label="option.label"
          :value="option.value"
        />
      </el-select>
      <el-date-picker
        v-else-if="field.type === 'date'"
        v-model="model[field.prop]"
        type="date"
        :placeholder="field.placeholder"
        :disabled="field.disabled"
      />
    </el-form-item>
    <el-form-item v-if="$slots.action" class="form-actions">
      <slot name="action">
        <el-button type="primary" :loading="loading" @click="handleSubmit">Submit</el-button>
        <el-button @click="handleReset">Reset</el-button>
      </slot>
    </el-form-item>
  </el-form>
</template>

<style lang="scss" scoped>
.common-form {
  .form-actions {
    margin-top: 24px;
  }
}
</style>
