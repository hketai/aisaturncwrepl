<script setup>
import { useI18n } from 'vue-i18n';

const emit = defineEmits(['change']);

const { t } = useI18n();

const modelValue = defineModel({
  type: Boolean,
  default: false,
});

const updateValue = () => {
  modelValue.value = !modelValue.value;
  emit('change', !modelValue.value);
};
</script>

<template>
  <button
    type="button"
    class="relative h-4 transition-colors duration-200 ease-in-out rounded-full w-7 focus:outline-none focus:ring-1 focus:ring-indigo-600 focus:ring-offset-slate-100 focus:ring-offset-2 flex-shrink-0"
    :class="modelValue ? 'bg-indigo-600' : 'bg-slate-500 disabled:bg-slate-500/60'"
    role="switch"
    :aria-checked="modelValue"
    @click="updateValue"
  >
    <span class="sr-only">{{ t('SWITCH.TOGGLE') }}</span>
    <span
      class="absolute top-0.5 left-0.5 h-3 w-3 transform rounded-full shadow-sm transition-transform duration-200 ease-in-out"
      :class="
        modelValue
          ? 'translate-x-3 bg-white'
          : 'translate-x-0 bg-white'
      "
    />
  </button>
</template>
