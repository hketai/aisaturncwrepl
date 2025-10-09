<script setup>
import { computed } from 'vue';
import { dateRanges } from '../helpers/DatePickerHelper';
import { format, isSameYear, isValid } from 'date-fns';

const props = defineProps({
  selectedStartDate: Date,
  selectedEndDate: Date,
  selectedRange: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['open']);

const formatDateRange = computed(() => {
  const startDate = props.selectedStartDate;
  const endDate = props.selectedEndDate;

  if (!isValid(startDate) || !isValid(endDate)) {
    return 'Select a date range';
  }

  const formatString = isSameYear(startDate, endDate)
    ? 'MMM d' // Same year: "Apr 1"
    : 'MMM d yyyy'; // Different years: "Apr 1 2025"

  if (isSameYear(startDate, new Date()) && isSameYear(endDate, new Date())) {
    // Both dates are in the current year
    return `${format(startDate, 'MMM d')} - ${format(endDate, 'MMM d')}`;
  }
  // At least one date is not in the current year
  return `${format(startDate, formatString)} - ${format(
    endDate,
    formatString
  )}`;
});

const activeDateRange = computed(
  () => dateRanges.find(range => range.value === props.selectedRange).label
);

const openDatePicker = () => {
  emit('open');
};
</script>

<template>
  <button
    class="inline-flex relative items-center rounded-lg gap-2 py-1.5 px-3 h-8 bg-slate-900/10 hover:bg-slate-900/5 active:bg-slate-900/5"
    @click="openDatePicker"
  >
    <fluent-icon class="text-slate-900" icon="calendar" size="16" />
    <span class="text-sm font-medium text-slate-900">
      {{ $t(activeDateRange) }}
    </span>
    <span class="text-sm font-medium text-slate-900">
      {{ formatDateRange }}
    </span>
    <fluent-icon class="text-slate-900" icon="chevron-down" size="14" />
  </button>
</template>
