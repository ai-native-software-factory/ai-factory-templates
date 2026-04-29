<script setup lang="ts">
const currentYear = new Date().getFullYear()
</script>

<template>
  <footer class="common-footer">
    <p class="copyright">
      © {{ currentYear }} Vue Application. All rights reserved.
    </p>
  </footer>
</template>

<style lang="scss" scoped>
.common-footer {
  @include flex-center;
  height: 60px;
  padding: 0 20px;
  background: #ffffff;
  border-top: 1px solid $border-lighter;

  .copyright {
    font-size: $font-size-small;
    color: $text-secondary;
  }
}
</style>
