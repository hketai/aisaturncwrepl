<script setup>
import { computed } from 'vue';
import { useToggle } from '@vueuse/core';
import { dynamicTime } from 'shared/helpers/timeHelper';

import CardLayout from 'dashboard/components-next/CardLayout.vue';
import DropdownMenu from 'dashboard/components-next/dropdown-menu/DropdownMenu.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  id: {
    type: Number,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  updatedAt: {
    type: [String, Number],
    required: true,
  },
});

const emit = defineEmits(['action']);

const [showActionsDropdown, toggleDropdown] = useToggle();

const menuItems = [
  {
    label: 'View Knowledge Sources',
    value: 'viewKnowledge',
    action: 'viewKnowledge',
    icon: 'i-lucide-book-open',
  },
  {
    label: 'Inbox Connections',
    value: 'inboxConnections',
    action: 'inboxConnections',
    icon: 'i-lucide-link',
  },
  {
    label: 'Edit Agent',
    value: 'edit',
    action: 'edit',
    icon: 'i-lucide-pencil-line',
  },
  {
    label: 'Delete Agent',
    value: 'delete',
    action: 'delete',
    icon: 'i-lucide-trash',
  },
];

const lastUpdatedAt = computed(() => {
  const timestamp = typeof props.updatedAt === 'string' 
    ? Math.floor(new Date(props.updatedAt).getTime() / 1000)
    : props.updatedAt;
  return dynamicTime(timestamp);
});

const handleAction = ({ action, value }) => {
  toggleDropdown(false);
  emit('action', { action, value, id: props.id });
};
</script>

<template>
  <CardLayout>
    <div class="flex justify-between w-full gap-1">
      <div class="flex-1 min-w-0">
        <h3 class="text-base text-n-slate-12 line-clamp-1 font-medium">
          {{ name }}
        </h3>
      </div>
      <div class="flex items-center gap-2">
        <div
          v-on-clickaway="() => toggleDropdown(false)"
          class="relative flex items-center group"
        >
          <Button
            icon="i-lucide-ellipsis-vertical"
            color="slate"
            size="xs"
            class="rounded-md group-hover:bg-n-alpha-2"
            @click="toggleDropdown()"
          />
          <DropdownMenu
            v-if="showActionsDropdown"
            :menu-items="menuItems"
            class="mt-1 ltr:right-0 rtl:left-0 top-full"
            @action="handleAction($event)"
          />
        </div>
      </div>
    </div>
    <div class="flex items-center justify-between w-full gap-4">
      <span class="text-sm truncate text-n-slate-11">
        {{ description || 'No description' }}
      </span>
      <span class="text-sm text-n-slate-11 line-clamp-1 shrink-0">
        {{ lastUpdatedAt }}
      </span>
    </div>
  </CardLayout>
</template>
