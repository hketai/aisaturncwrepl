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
      
      <div class="flex items-center gap-2 pt-4 mt-2 border-t border-n-weak">
        <Button
          icon="i-lucide-book-open"
          color="blue"
          size="sm"
          class="flex-1"
          @click="handleAction('viewKnowledge')"
        >
          Knowledge
        </Button>
        
        <Button
          icon="i-lucide-link"
          color="teal"
          size="sm"
          class="flex-1"
          @click="handleAction('inboxConnections')"
        >
          Inboxes
        </Button>
        
        <Button
          icon="i-lucide-pencil-line"
          color="slate"
          size="sm"
          class="flex-1"
          @click="handleAction('edit')"
        >
          Edit
        </Button>
        
        <Button
          icon="i-lucide-trash"
          color="ruby"
          size="sm"
          @click="handleAction('delete')"
        />
      </div>
    </div>
  </CardLayout>
</template>
