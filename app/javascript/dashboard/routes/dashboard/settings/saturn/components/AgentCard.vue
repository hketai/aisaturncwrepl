<script setup>
import { computed } from 'vue';
import { dynamicTime } from 'shared/helpers/timeHelper';

import CardLayout from 'dashboard/components-next/CardLayout.vue';
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

const lastUpdatedAt = computed(() => {
  const timestamp = typeof props.updatedAt === 'string' 
    ? Math.floor(new Date(props.updatedAt).getTime() / 1000)
    : props.updatedAt;
  return dynamicTime(timestamp);
});

const handleAction = (action) => {
  emit('action', { action, id: props.id });
};
</script>

<template>
  <CardLayout>
    <div class="flex flex-col gap-3 w-full">
      <div class="flex justify-between w-full gap-2">
        <div class="flex-1 min-w-0">
          <h3 class="text-base text-n-slate-12 line-clamp-1 font-medium mb-1">
            {{ name }}
          </h3>
          <p class="text-sm text-n-slate-11 line-clamp-2">
            {{ description || 'No description' }}
          </p>
        </div>
        <span class="text-xs text-n-slate-11 shrink-0">
          {{ lastUpdatedAt }}
        </span>
      </div>
      
      <div class="flex items-center gap-2 pt-2 border-t border-n-weak">
        <Button
          color="slate"
          size="xs"
          class="flex-1"
          @click="handleAction('viewKnowledge')"
        >
          <template #prefixIcon>
            <i class="i-lucide-book-open"></i>
          </template>
          Knowledge
        </Button>
        
        <Button
          color="slate"
          size="xs"
          class="flex-1"
          @click="handleAction('inboxConnections')"
        >
          <template #prefixIcon>
            <i class="i-lucide-link"></i>
          </template>
          Inboxes
        </Button>
        
        <Button
          color="slate"
          size="xs"
          class="flex-1"
          @click="handleAction('edit')"
        >
          <template #prefixIcon>
            <i class="i-lucide-pencil-line"></i>
          </template>
          Edit
        </Button>
        
        <Button
          icon="i-lucide-trash"
          color="slate"
          size="xs"
          class="hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-900/20"
          @click="handleAction('delete')"
        />
      </div>
    </div>
  </CardLayout>
</template>
