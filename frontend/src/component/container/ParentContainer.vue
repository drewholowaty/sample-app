<script setup>
const props = defineProps(['color'])
</script>

<template>
  <div class="PC-p">
    <slot></slot>
  </div>
</template>

<style scoped>
.PC-p {
  width: 100vw;
  height: 100vh;
  background-color: v-bind('props.color');
  overflow: hidden;
}
</style>
