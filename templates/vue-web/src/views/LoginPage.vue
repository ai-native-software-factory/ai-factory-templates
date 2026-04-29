<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElForm, ElFormItem, ElInput, ElButton, ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()

const formRef = ref()
const loading = ref(false)

const formData = reactive({
  username: '',
  password: '',
})

const rules = {
  username: [{ required: true, message: 'Please enter username', trigger: 'blur' }],
  password: [
    { required: true, message: 'Please enter password', trigger: 'blur' },
    { min: 6, message: 'Password must be at least 6 characters', trigger: 'blur' },
  ],
}

async function handleLogin() {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    loading.value = true

    await authStore.login({
      username: formData.username,
      password: formData.password,
    })

    ElMessage.success('Login successful')
    router.push('/')
  } catch (error) {
    ElMessage.error('Login failed, please check your credentials')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <h1 class="login-title">Vue Admin</h1>
          <p class="login-subtitle">Welcome back, please login to continue</p>
        </div>

        <el-form
          ref="formRef"
          :model="formData"
          :rules="rules"
          class="login-form"
          @submit.prevent="handleLogin"
        >
          <el-form-item prop="username">
            <el-input
              v-model="formData.username"
              placeholder="Username"
              size="large"
              :prefix-icon="User"
            />
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              v-model="formData.password"
              type="password"
              placeholder="Password"
              size="large"
              :prefix-icon="Lock"
              show-password
              @keyup.enter="handleLogin"
            />
          </el-form-item>
          <el-form-item>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              class="login-button"
              @click="handleLogin"
            >
              Login
            </el-button>
          </el-form-item>
        </el-form>

        <div class="login-footer">
          <p class="demo-hint">
            Demo account: admin / admin123
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

  .login-container {
    width: 100%;
    max-width: 420px;
    padding: 20px;

    .login-card {
      background: #ffffff;
      border-radius: 12px;
      padding: 40px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);

      .login-header {
        text-align: center;
        margin-bottom: 32px;

        .login-title {
          font-size: 28px;
          font-weight: 700;
          color: $text-primary;
          margin-bottom: 8px;
        }

        .login-subtitle {
          font-size: $font-size-base;
          color: $text-secondary;
        }
      }

      .login-form {
        .login-button {
          width: 100%;
        }
      }

      .login-footer {
        margin-top: 24px;
        text-align: center;

        .demo-hint {
          font-size: $font-size-small;
          color: $text-placeholder;
        }
      }
    }
  }
}
</style>
