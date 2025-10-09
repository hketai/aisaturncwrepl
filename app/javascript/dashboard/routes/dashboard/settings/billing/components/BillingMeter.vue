<script setup>
import { computed } from 'vue';
const props = defineProps({
  title: {
    type: String,
    required: true,
  },
  consumed: {
    type: Number,
    required: true,
  },
  totalCount: {
    type: Number,
    required: true,
  },
});

const percent = computed(() =>
  Math.round((props.consumed / props.totalCount) * 100)
);

const colorClass = computed(() => {
  if (percent.value < 50) {
    return 'bg-teal-900';
  }
  if (percent.value < 80) {
    return 'bg-amber-900';
  }
  return 'bg-red-900';
});
</script>

<template>
  <div
    class="flex gap-5 items-center justify-between text-xs uppercase text-slate-900"
  >
    <div class="font-medium tracking-wider">
      {{ title }}
    </div>
    <div class="tabular-nums">{{ consumed }} / {{ totalCount }}</div>
  </div>
  <div class="rounded-full overflow-hidden h-2 w-full bg-slate-300 mt-2">
    <div class="h-2" :class="colorClass" :style="{ width: `${percent}%` }" />
  </div>
</template>
