<script setup>
import { computed, useSlots } from 'vue';
import { useRouter } from 'vue-router';
import Button from 'dashboard/components-next/button/Button.vue';

const router = useRouter();

const props = defineProps({
  headerTitle: {
    type: String,
    required: true,
  },
  backUrl: {
    type: [String, Object],
    default: null,
  },
  buttonLabel: {
    type: String,
    default: null,
  },
  isFetching: {
    type: Boolean,
    default: false,
  },
  isEmpty: {
    type: Boolean,
    default: false,
  },
  showPaginationFooter: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['click']);

const showHeaderActions = computed(() => {
  return props.buttonLabel || !!useSlots()['header-actions'];
});

const handleClick = () => {
  emit('click');
};

const handleBack = () => {
  if (props.backUrl) {
    if (typeof props.backUrl === 'string') {
      router.push(props.backUrl);
    } else {
      router.push(props.backUrl);
    }
  }
};
</script>

<template>
  <div class="flex flex-col h-full">
    <div class="flex items-center justify-between p-4 border-b border-n-weak">
      <div class="flex items-center gap-3">
        <Button
          v-if="backUrl"
          icon="i-lucide-arrow-left"
          color="slate"
          size="sm"
          @click="handleBack"
        />
        <h1 class="text-xl font-semibold text-n-slate-12">
          {{ headerTitle }}
        </h1>
      </div>

      <div v-if="showHeaderActions" class="flex items-center gap-2">
        <slot name="header-actions">
          <Button
            v-if="buttonLabel"
            icon="i-lucide-plus"
            @click="handleClick"
          >
            {{ buttonLabel }}
          </Button>
        </slot>
      </div>
    </div>

    <div class="flex-1 overflow-auto p-4">
      <div v-if="isFetching" class="flex items-center justify-center py-16">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>

      <div v-else-if="isEmpty">
        <slot name="emptyState" />
      </div>

      <div v-else>
        <slot name="body">
          <slot />
        </slot>
      </div>
    </div>

    <div v-if="showPaginationFooter" class="border-t border-n-weak p-4">
      <slot name="pagination" />
    </div>
  </div>
</template>
