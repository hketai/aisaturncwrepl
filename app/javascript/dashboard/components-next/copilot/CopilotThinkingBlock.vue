<script setup>
import Icon from '../../components-next/icon/Icon.vue';
defineProps({
  content: {
    type: String,
    required: true,
  },
});
</script>

<template>
  <div
    class="flex flex-col gap-2 p-3 rounded-lg bg-white/50 border border-slate-300 hover:bg-white/80 transition-colors duration-200"
  >
    <div class="flex items-start gap-2">
      <Icon
        icon="i-lucide-sparkles"
        class="w-4 h-4 mt-0.5 flex-shrink-0 text-slate-800"
      />
      <div class="text-sm text-slate-900">
        {{ content }}
      </div>
    </div>
  </div>
</template>
