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
  <section class="flex flex-col w-full h-full overflow-hidden bg-n-background">
    <header class="sticky top-0 z-10 px-6">
      <div class="w-full max-w-[60rem] mx-auto">
        <div
          class="flex items-start lg:items-center justify-between w-full py-6 lg:py-0 lg:h-20 gap-4 lg:gap-2 flex-col lg:flex-row"
        >
          <div class="flex gap-4 items-center">
            <Button
              v-if="backUrl"
              icon="i-lucide-arrow-left"
              color="slate"
              size="sm"
              @click="handleBack"
            />
            <slot name="headerTitle">
              <span class="text-xl font-medium text-n-slate-12">
                {{ headerTitle }}
              </span>
            </slot>
          </div>

          <div v-if="showHeaderActions" class="flex items-center gap-2">
            <slot name="header-actions">
              <Button
                v-if="buttonLabel"
                :label="buttonLabel"
                icon="i-lucide-plus"
                size="sm"
                @click="handleClick"
              />
            </slot>
          </div>
        </div>
      </div>
    </header>

    <main class="flex-1 px-6 overflow-y-auto">
      <div class="w-full max-w-[60rem] h-full mx-auto py-4">
        <div
          v-if="isFetching"
          class="flex items-center justify-center py-10 text-n-slate-11"
        >
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
    </main>

    <footer v-if="showPaginationFooter" class="sticky bottom-0 z-10 px-4 pb-4">
      <slot name="pagination" />
    </footer>
  </section>
</template>
