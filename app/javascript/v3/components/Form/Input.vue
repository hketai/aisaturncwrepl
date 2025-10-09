<script setup>
import { defineProps, defineModel } from 'vue';
import WithLabel from './WithLabel.vue';

defineProps({
  label: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    default: 'text',
  },
  icon: {
    type: String,
    default: '',
  },
  name: {
    type: String,
    required: true,
  },
  hasError: Boolean,
  errorMessage: {
    type: String,
    default: '',
  },
  spacing: {
    type: String,
    default: 'base',
    validator: value => ['base', 'compact'].includes(value),
  },
});

defineOptions({
  inheritAttrs: false,
});

const model = defineModel({
  type: [String, Number],
  required: true,
});
</script>

<template>
  <WithLabel
    :label="label"
    :icon="icon"
    :name="name"
    :has-error="hasError"
    :error-message="errorMessage"
  >
    <template #rightOfLabel>
      <slot />
    </template>
    <input
      v-bind="$attrs"
      v-model="model"
      :type="type"
      class="block w-full border-none rounded-md shadow-sm bg-slate-900/10 appearance-none outline outline-1 focus:outline focus:outline-1 text-slate-900 placeholder:text-slate-900 sm:text-sm sm:leading-6 px-3 py-3"
      :class="{
        'error outline-red-700 dark:outline-red-700 hover:outline-red-800 dark:hover:outline-red-800 disabled:outline-red-700 dark:disabled:outline-red-700':
          hasError,
        'outline-slate-300 dark:outline-slate-300 hover:outline-slate-500 dark:hover:outline-slate-500 focus:outline-indigo-600 dark:focus:outline-indigo-600':
          !hasError,
        'px-3 py-3': spacing === 'base',
        'px-3 py-2 mb-0': spacing === 'compact',
        'pl-9': icon,
      }"
    />
  </WithLabel>
</template>
