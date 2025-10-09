<script setup>
import { computed, ref, watch, useSlots } from 'vue';

import WootEditor from 'dashboard/components/widgets/WootWriter/Editor.vue';

const props = defineProps({
  modelValue: { type: String, default: '' },
  label: { type: String, default: '' },
  placeholder: { type: String, default: '' },
  focusOnMount: { type: Boolean, default: false },
  maxLength: { type: Number, default: 200 },
  showCharacterCount: { type: Boolean, default: true },
  disabled: { type: Boolean, default: false },
  message: { type: String, default: '' },
  messageType: {
    type: String,
    default: 'info',
    validator: value => ['info', 'error', 'success'].includes(value),
  },
  enableVariables: { type: Boolean, default: false },
  enableCannedResponses: { type: Boolean, default: true },
  enabledMenuOptions: { type: Array, default: () => [] },
  enableCaptainTools: { type: Boolean, default: false },
});

const emit = defineEmits(['update:modelValue']);

const slots = useSlots();

const isFocused = ref(false);

const characterCount = computed(() => props.modelValue.length);

const messageClass = computed(() => {
  switch (props.messageType) {
    case 'error':
      return 'text-red-800 dark:text-red-800';
    case 'success':
      return 'text-teal-900 dark:text-teal-900';
    default:
      return 'text-slate-900 dark:text-slate-900';
  }
});

const handleInput = value => {
  if (!props.disabled) {
    emit('update:modelValue', value);
  }
};

const handleFocus = () => {
  if (!props.disabled) {
    isFocused.value = true;
  }
};

const handleBlur = () => {
  if (!props.disabled) {
    isFocused.value = false;
  }
};

watch(
  () => props.modelValue,
  newValue => {
    if (props.maxLength && props.showCharacterCount && !slots.actions) {
      if (characterCount.value >= props.maxLength) {
        emit('update:modelValue', newValue.slice(0, props.maxLength));
      }
    }
  }
);
</script>

<template>
  <div class="flex flex-col min-w-0 gap-1">
    <label v-if="label" class="mb-0.5 text-sm font-medium text-slate-900">
      {{ label }}
    </label>
    <div
      class="flex flex-col w-full gap-2 px-3 py-3 transition-all duration-500 ease-in-out border rounded-lg editor-wrapper bg-slate-900/10"
      :class="[
        {
          'cursor-not-allowed opacity-50 pointer-events-none !bg-slate-900/10 disabled:border-slate-300 dark:disabled:border-slate-300':
            disabled,
          'border-indigo-600 dark:border-indigo-600': isFocused,
          'hover:border-slate-500 dark:hover:border-slate-500 border-slate-300 dark:border-slate-300':
            !isFocused && messageType !== 'error',
          'border-red-700 dark:border-red-700 hover:border-red-800 dark:hover:border-red-800':
            messageType === 'error' && !isFocused,
        },
      ]"
    >
      <WootEditor
        :model-value="modelValue"
        :placeholder="placeholder"
        :focus-on-mount="focusOnMount"
        :disabled="disabled"
        :enable-variables="enableVariables"
        :enable-canned-responses="enableCannedResponses"
        :enabled-menu-options="enabledMenuOptions"
        :enable-captain-tools="enableCaptainTools"
        @input="handleInput"
        @focus="handleFocus"
        @blur="handleBlur"
      />
      <div
        v-if="showCharacterCount || slots.actions"
        class="flex items-center justify-end h-4 ltr:right-3 rtl:left-3"
      >
        <span
          v-if="showCharacterCount && !slots.actions"
          class="text-xs tabular-nums text-slate-900"
        >
          {{ characterCount }} / {{ maxLength }}
        </span>
        <slot v-else name="actions" />
      </div>
    </div>
    <p
      v-if="message"
      class="min-w-0 mt-1 mb-0 text-xs truncate transition-all duration-500 ease-in-out"
      :class="messageClass"
    >
      {{ message }}
    </p>
  </div>
</template>

<style lang="scss" scoped>
.editor-wrapper {
  ::v-deep {
    .ProseMirror-menubar-wrapper {
      @apply gap-2 !important;

      .ProseMirror-menubar {
        @apply bg-transparent dark:bg-transparent w-fit left-1 pt-0 h-5 !top-0 !relative !important;

        .ProseMirror-menuitem {
          @apply h-5 !important;
        }

        .ProseMirror-icon {
          @apply p-1 w-3 h-3 text-slate-900 dark:text-slate-900 !important;
        }
      }
      .ProseMirror.ProseMirror-woot-style {
        p {
          @apply first:mt-0 !important;
        }

        .empty-node {
          @apply m-0 !important;

          &::before {
            @apply text-slate-900 dark:text-slate-900;
          }
        }
      }
    }
  }
}
</style>
