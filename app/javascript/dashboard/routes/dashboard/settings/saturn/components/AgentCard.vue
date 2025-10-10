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
  enabled: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits(['action', 'toggle-status']);

const lastUpdatedAt = computed(() => {
  const timestamp = typeof props.updatedAt === 'string' 
    ? Math.floor(new Date(props.updatedAt).getTime() / 1000)
    : props.updatedAt;
  return dynamicTime(timestamp);
});

const handleAction = (action) => {
  emit('action', { action, id: props.id });
};

const handleToggle = () => {
  emit('toggle-status', { id: props.id, enabled: !props.enabled });
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
            {{ description || $t('SATURN.AGENTS.NO_DESCRIPTION') }}
          </p>
        </div>
        <div class="flex items-center gap-3 shrink-0">
          <button
            type="button"
            :class="[
              'relative h-4 transition-colors duration-200 ease-in-out rounded-full w-7',
              'focus:outline-none focus:ring-1 focus:ring-n-brand focus:ring-offset-n-slate-2 focus:ring-offset-2',
              'flex-shrink-0',
              enabled ? 'bg-n-brand' : 'bg-n-slate-6'
            ]"
            role="switch"
            :aria-checked="enabled"
            @click="handleToggle"
          >
            <span class="sr-only">{{ $t('SATURN.AGENTS.TOGGLE_STATUS') }}</span>
            <span
              :class="[
                'absolute top-0.5 left-0.5 h-3 w-3 transform rounded-full shadow-sm',
                'transition-transform duration-200 ease-in-out bg-n-background',
                enabled ? 'translate-x-3' : 'translate-x-0'
              ]"
            ></span>
          </button>
          <span class="text-xs text-n-slate-11">
            {{ lastUpdatedAt }}
          </span>
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
          icon="i-lucide-user-round-search"
          color="slate"
          size="sm"
          class="flex-1"
          @click="handleAction('handoff')"
        >
          {{ $t('SATURN.AGENTS.HANDOFF_BUTTON') }}
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
