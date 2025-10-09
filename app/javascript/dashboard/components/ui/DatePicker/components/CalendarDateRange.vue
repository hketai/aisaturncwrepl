<script setup>
import { dateRanges } from '../helpers/DatePickerHelper';

defineProps({
  selectedRange: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['setRange']);

const setDateRange = range => {
  emit('setRange', range);
};
</script>

<template>
  <div class="w-[200px] flex flex-col items-start">
    <h4
      class="w-full px-5 py-4 text-sm font-medium capitalize text-start text-slate-900"
    >
      {{ $t('DATE_PICKER.DATE_RANGE_OPTIONS.TITLE') }}
    </h4>
    <div class="flex flex-col items-start w-full">
      <button
        v-for="range in dateRanges"
        :key="range.label"
        class="w-full px-5 py-3 text-sm font-medium truncate border-none rounded-none text-start hover:bg-slate-900/10 dark:hover:bg-slate-300"
        :class="
          range.value === selectedRange
            ? 'text-slate-900 bg-slate-900/5 dark:bg-slate-200'
            : 'text-slate-900'
        "
        @click="setDateRange(range)"
      >
        {{ $t(range.label) }}
      </button>
    </div>
  </div>
</template>
