<script setup>
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

defineProps({
  message: { type: String, default: '' },
});
</script>

<template>
  <div class="flex items-center justify-center p-8">
    <h6
      class="flex items-center gap-3 text-base text-center w-100 text-slate-900"
    >
      <span class="text-base font-medium text-slate-900">
        {{ message }}
      </span>
      <Spinner class="text-indigo-600" />
    </h6>
  </div>
</template>
