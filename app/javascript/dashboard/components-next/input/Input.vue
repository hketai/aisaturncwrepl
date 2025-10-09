<script setup>
import { computed, ref, onMounted, nextTick, getCurrentInstance } from 'vue';
const props = defineProps({
  modelValue: { type: [String, Number], default: '' },
  type: { type: String, default: 'text' },
  customInputClass: { type: [String, Object, Array], default: '' },
  placeholder: { type: String, default: '' },
  label: { type: String, default: '' },
  id: { type: String, default: '' },
  size: {
    type: String,
    default: 'md',
    validator: value => ['sm', 'md'].includes(value),
  },
  message: { type: String, default: '' },
  disabled: { type: Boolean, default: false },
  messageType: {
    type: String,
    default: 'info',
    validator: value => ['info', 'error', 'success'].includes(value),
  },
  min: { type: String, default: '' },
  max: { type: String, default: '' },
  autofocus: { type: Boolean, default: false },
});

const emit = defineEmits([
  'update:modelValue',
  'blur',
  'input',
  'focus',
  'enter',
]);

// Generate a unique ID per component instance when `id` prop is not provided.
const { uid } = getCurrentInstance();
const uniqueId = computed(() => props.id || `input-${uid}`);

const isFocused = ref(false);
const inputRef = ref(null);

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

const inputOutlineClass = computed(() => {
  switch (props.messageType) {
    case 'error':
      return 'outline-red-700 dark:outline-red-700 hover:outline-red-800 dark:hover:outline-red-800 disabled:outline-red-700 dark:disabled:outline-red-700';
    default:
      return 'outline-slate-300 dark:outline-slate-300 hover:outline-slate-500 dark:hover:outline-slate-500 disabled:outline-slate-300 dark:disabled:outline-slate-300 focus:outline-indigo-600 dark:focus:outline-indigo-600';
  }
});

const handleInput = event => {
  let value = event.target.value;
  // Convert to number if type is number and value is not empty
  if (props.type === 'number' && value !== '') {
    value = Number(value);
  }
  emit('update:modelValue', value);
  emit('input', event);
};

const handleFocus = event => {
  emit('focus', event);
  isFocused.value = true;
};

const sizeClass = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'h-8 !px-3 !py-2';
    case 'md':
      return 'h-10 !px-3 !py-2.5';
    default:
      return 'h-10 !px-3 !py-2.5';
  }
});

const handleBlur = event => {
  emit('blur', event);
  isFocused.value = false;
};

const handleEnter = event => {
  emit('enter', event);
};

onMounted(() => {
  if (props.autofocus) {
    nextTick(() => {
      inputRef.value?.focus();
    });
  }
});
</script>

<template>
  <div class="relative flex flex-col min-w-0 gap-1">
    <label
      v-if="label"
      :for="uniqueId"
      class="mb-0.5 text-sm font-medium text-slate-900"
    >
      {{ label }}
    </label>
    <!-- Added prefix slot to allow adding icons to the input -->
    <slot name="prefix" />
    <input
      :id="uniqueId"
      v-bind="$attrs"
      ref="inputRef"
      :value="modelValue"
      :class="[
        customInputClass,
        inputOutlineClass,
        sizeClass,
        {
          error: messageType === 'error',
          focus: isFocused,
        },
      ]"
      :type="type"
      :placeholder="placeholder"
      :disabled="disabled"
      :min="['date', 'datetime-local', 'time'].includes(type) ? min : undefined"
      :max="
        ['date', 'datetime-local', 'time', 'number'].includes(type)
          ? max
          : undefined
      "
      class="block w-full reset-base text-sm !mb-0 outline outline-1 border-none border-0 outline-offset-[-1px] rounded-md bg-white dark:bg-slate-200 shadow-sm file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-slate-900 dark:placeholder:text-slate-900 disabled:cursor-not-allowed disabled:opacity-50 text-slate-900 transition-all duration-200 ease-in-out [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      @keyup.enter="handleEnter"
    />
    <p
      v-if="message"
      class="min-w-0 mt-1 mb-0 text-xs truncate transition-all duration-500 ease-in-out"
      :class="messageClass"
    >
      {{ message }}
    </p>
  </div>
</template>
