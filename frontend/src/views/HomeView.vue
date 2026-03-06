<script setup>
  import ParentContainer from "@/component/container/ParentContainer.vue"
</script>

<template>
  <ParentContainer color="green">
    <div class="HV-p">
      <div class="HV-c0">
        <h1>Hello World</h1>
        <p>This is your custom application.</p>
      </div>
    </div>
  </ParentContainer>
</template>

<style scoped>
.HV-p {
  width: 100%;
  height: 100%;
  display: flex;
  flex-flow: column nowrap;
  align-items: center;
}

.HV-c0 {
  margin-top: 50px;
  width: 300px;
  border: solid;
  background-color: white;
  display: flex;
  flex-flow: column nowrap;
  align-items: center;
}
</style>
