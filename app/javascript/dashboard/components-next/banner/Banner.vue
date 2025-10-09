<!-- DEPRECIATED -->
<!-- TODO: Replace this banner component with NextBanner "app/javascript/dashboard/components-next/banner/Banner.vue" -->
<script setup>
import { computed } from 'vue';

const props = defineProps({
  color: {
    type: String,
    default: 'slate',
    validator: value =>
      ['blue', 'ruby', 'amber', 'slate', 'teal'].includes(value),
  },
  actionLabel: {
    type: String,
    default: null,
  },
});

const emit = defineEmits(['action']);

const bannerClass = computed(() => {
  const classMap = {
    slate: 'bg-slate-200 border-slate-300 text-slate-900',
    amber: 'bg-amber-200 border-amber-300 text-amber-900',
    teal: 'bg-teal-200 border-teal-300 text-teal-900',
    ruby: 'bg-red-200 border-red-300 text-red-900',
    blue: 'bg-indigo-200 border-indigo-300 text-indigo-900',
  };

  return classMap[props.color];
});

const buttonClass = computed(() => {
  const classMap = {
    slate: 'bg-slate-300 hover:bg-slate-400 text-slate-900',
    amber: 'bg-amber-300 hover:bg-amber-400 text-amber-900',
    teal: 'bg-teal-300 hover:bg-teal-400 text-teal-900',
    ruby: 'bg-red-300 hover:bg-red-400 text-red-900',
    blue: 'bg-indigo-300 hover:bg-indigo-400 text-indigo-900',
  };

  return classMap[props.color];
});

const triggerAction = () => {
  emit('action');
};
</script>

<template>
  <div
    class="text-sm rounded-xl flex items-center justify-between gap-2 border"
    :class="[
      bannerClass,
      {
        'py-2 px-3': !actionLabel,
        'pl-3 p-2': actionLabel,
      },
    ]"
  >
    <div>
      <slot />
    </div>
    <div>
      <button
        v-if="actionLabel"
        class="px-3 py-1 w-auto grid place-content-center rounded-lg"
        :class="buttonClass"
        @click="triggerAction"
      >
        {{ actionLabel }}
      </button>
    </div>
  </div>
</template>
