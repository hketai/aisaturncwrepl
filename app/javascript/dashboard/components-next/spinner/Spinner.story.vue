<script setup>
import Spinner from './Spinner.vue';
</script>

<template>
  <Story title="Components/Spinner" :layout="{ type: 'grid', width: '400' }">
    <Variant title="Default">
      <Spinner size="24" class="text-slate-900" />
      <Spinner size="32" class="text-red-900" />
      <Spinner size="40" class="text-amber-900" />
      <Spinner size="48" class="text-teal-900" />
      <Spinner size="64" class="text-indigo-600" />
    </Variant>
  </Story>
</template>
