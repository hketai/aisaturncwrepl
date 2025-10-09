<script setup>
import { isVNode, computed } from 'vue';
import Icon from 'next/icon/Icon.vue';
import Policy from 'dashboard/components/policy.vue';
import { useSidebarContext } from './provider';

const props = defineProps({
  label: { type: String, required: true },
  to: { type: [String, Object], required: true },
  icon: { type: [String, Object], default: null },
  active: { type: Boolean, default: false },
  component: { type: Function, default: null },
});

const { resolvePermissions, resolveFeatureFlag } = useSidebarContext();

const shouldRenderComponent = computed(() => {
  return typeof props.component === 'function' || isVNode(props.component);
});
</script>

<!-- eslint-disable-next-line vue/no-root-v-if -->
<template>
  <Policy
    :permissions="resolvePermissions(to)"
    :feature-flag="resolveFeatureFlag(to)"
    as="li"
    class="py-0.5 ltr:pl-4 rtl:pr-4 rtl:mr-2 ltr:ml-2 relative text-slate-600 dark:text-slate-400"
  >
    <component
      :is="to ? 'router-link' : 'div'"
      :to="to"
      :title="label"
      class="flex h-8 items-center gap-2.5 px-3 py-1.5 rounded-md transition-all duration-150 group relative"
      :class="{
        'text-indigo-600 dark:text-indigo-400 bg-indigo-50/80 dark:bg-indigo-900/20 font-medium': active,
        'hover:bg-slate-100/80 dark:hover:bg-slate-800/40 hover:text-slate-900 dark:hover:text-slate-100': !active,
      }"
    >
      <div 
        v-if="active"
        class="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-4 bg-indigo-600 dark:bg-indigo-400 rounded-r-full"
      />
      <component
        :is="component"
        v-if="shouldRenderComponent"
        :label
        :icon
        :active
      />
      <template v-else>
        <Icon v-if="icon" :icon="icon" class="size-[16px] inline-block opacity-70 group-hover:opacity-100 transition-opacity" />
        <div class="flex-1 truncate min-w-0 text-[13px]">{{ label }}</div>
      </template>
    </component>
  </Policy>
</template>
