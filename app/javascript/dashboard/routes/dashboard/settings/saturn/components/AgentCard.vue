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
  active: {
    type: Boolean,
    default: true,
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
      <div class="flex justify-between items-start w-full gap-4">
        <div class="flex-1 min-w-0">
          <h3 class="text-base text-n-slate-12 line-clamp-1 font-medium mb-1">
            {{ name }}
          </h3>
          <p class="text-sm text-n-slate-11 line-clamp-2 mb-1">
            {{ description || $t('SATURN.AGENTS.NO_DESCRIPTION') }}
          </p>
          <span class="text-xs text-n-slate-11">
            {{ lastUpdatedAt }}
          </span>
        </div>
        
        <div class="flex items-center gap-2 shrink-0">
          <span class="text-xs font-semibold" :class="active ? 'text-indigo-600 dark:text-indigo-400' : 'text-slate-500 dark:text-slate-400'">
            {{ active ? $t('SATURN.AGENTS.ACTIVE') : $t('SATURN.AGENTS.PASSIVE') }}
          </span>
          <button
            type="button"
            :class="[
              'inline-flex items-center h-6 w-11 p-0.5 shrink-0 cursor-pointer rounded-full transition-colors duration-200 ease-in-out focus:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2',
              active ? 'bg-indigo-600 justify-end' : 'bg-slate-300 dark:bg-slate-600 justify-start'
            ]"
            :aria-pressed="active"
            :aria-label="active ? $t('SATURN.AGENTS.ACTIVE') : $t('SATURN.AGENTS.PASSIVE')"
            @click.stop="handleAction('toggleActive')"
          >
            <span class="h-5 w-5 rounded-full bg-white shadow-lg transition-all duration-200 ease-in-out" />
          </button>
        </div>
      </div>
      
      <div class="flex items-center gap-2 pt-4 mt-2 border-t border-n-weak">
        <Button
          icon="i-lucide-book-open"
          color="blue"
          size="sm"
          class="flex-1"
          @click="handleAction('viewKnowledge')"
        >
          {{ $t('SATURN.AGENTS.KNOWLEDGE_BUTTON') }}
        </Button>
        
        <Button
          icon="i-lucide-link"
          color="teal"
          size="sm"
          class="flex-1"
          @click="handleAction('inboxConnections')"
        >
          {{ $t('SATURN.AGENTS.INBOXES_BUTTON') }}
        </Button>
        
        <Button
          icon="i-lucide-pencil-line"
          color="slate"
          size="sm"
          class="flex-1"
          @click="handleAction('edit')"
        >
          {{ $t('SATURN.AGENTS.EDIT_BUTTON') }}
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
