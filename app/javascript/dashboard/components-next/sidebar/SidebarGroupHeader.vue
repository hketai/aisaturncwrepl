<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store.js';
import Icon from 'next/icon/Icon.vue';

const props = defineProps({
  to: { type: [Object, String], default: '' },
  label: { type: String, default: '' },
  icon: { type: [String, Object], default: '' },
  expandable: { type: Boolean, default: false },
  isExpanded: { type: Boolean, default: false },
  isActive: { type: Boolean, default: false },
  hasActiveChild: { type: Boolean, default: false },
  getterKeys: { type: Object, default: () => ({}) },
});

const emit = defineEmits(['toggle']);

const showBadge = useMapGetter(props.getterKeys.badge);
const dynamicCount = useMapGetter(props.getterKeys.count);
const count = computed(() =>
  dynamicCount.value > 99 ? '99+' : dynamicCount.value
);
</script>

<template>
  <component
    :is="to ? 'router-link' : 'div'"
    class="flex items-center gap-2.5 px-3 py-2 rounded-md h-9 min-w-0 relative transition-all duration-200 group"
    role="button"
    draggable="false"
    :to="to"
    :title="label"
    :class="{
      'text-n-brand-700 dark:text-n-brand-300 bg-n-brand-50 dark:bg-n-brand-900/30 font-semibold': isActive && !hasActiveChild,
      'text-n-slate-12 dark:text-n-slate-12 font-semibold': hasActiveChild,
      'text-n-slate-11 dark:text-n-slate-6 hover:bg-n-slate-2 dark:hover:bg-n-slate-3 hover:text-n-slate-12 dark:hover:text-n-slate-12': !isActive && !hasActiveChild,
    }"
    @click.stop="emit('toggle')"
  >
    <div 
      v-if="isActive && !hasActiveChild"
      class="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-n-brand-700 dark:bg-n-brand-400 rounded-r"
    />
    <div v-if="icon" class="relative flex items-center gap-2">
      <Icon v-if="icon" :icon="icon" class="size-[18px]" />
      <span
        v-if="showBadge"
        class="size-2 -top-px ltr:-right-px rtl:-left-px bg-n-brand-700 dark:bg-n-brand-400 absolute rounded-full border-2 border-white dark:border-n-slate-1"
      />
    </div>
    <div class="flex items-center gap-2 flex-grow min-w-0">
      <span class="text-[13px] font-medium leading-5 truncate">
        {{ label }}
      </span>
      <span
        v-if="dynamicCount && !expandable"
        class="rounded-full capitalize text-[11px] leading-4 font-bold text-center px-2 py-0.5 flex-shrink-0"
        :class="{
          'text-n-brand-800 dark:text-n-brand-200 bg-n-brand-100 dark:bg-n-brand-900/50 font-bold': isActive,
          'text-n-slate-10 dark:text-n-slate-7 bg-n-slate-3 dark:bg-n-slate-4 font-semibold': !isActive,
        }"
      >
        {{ count }}
      </span>
    </div>
    <span
      v-if="expandable"
      v-show="isExpanded"
      class="i-ph-caret-up-bold size-3.5 opacity-60 group-hover:opacity-100 transition-opacity"
      @click.stop="emit('toggle')"
    />
  </component>
</template>
