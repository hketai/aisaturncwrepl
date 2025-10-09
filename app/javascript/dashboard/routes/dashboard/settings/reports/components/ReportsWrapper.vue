<template>
  <div class="reports--wrapper overflow-auto bg-white w-full px-6">
    <div class="max-w-[60rem] mx-auto pb-12">
      <router-view />
    </div>
  </div>
</template>

<style scoped lang="scss">
.reports--wrapper {
  :deep() {
    .multiselect--disabled {
      @apply opacity-50 border border-slate-300 rounded-md cursor-not-allowed;
    }

    .multiselect__content-wrapper {
      @apply bg-slate-200 border border-slate-300 text-slate-900;
    }

    .multiselect__tags {
      @apply bg-slate-50 border border-slate-300 m-0 min-h-[2.875rem] pt-0;

      input[type='text'] {
        @apply bg-slate-900/15 border-slate-300 placeholder:text-slate-900 min-h-[2.375rem] h-[2.375rem] px-0.5 py-0 text-sm;
      }
    }

    .multiselect__placeholder {
      @apply text-slate-900;
    }

    .multiselect__select {
      @apply min-h-0;
    }

    .multiselect__single {
      @apply bg-slate-900/15 text-slate-900;
    }

    .multiselect__input {
      @apply text-sm h-[2.375rem] mb-0 py-0;
    }

    .multiselect__tags,
    .multiselect__input,
    .multiselect {
      @apply bg-slate-900/15 !border-slate-300 text-slate-900 rounded-lg text-sm min-h-[2.5rem];
    }

    .mx-input-wrapper {
      @apply bg-slate-900/15 border-slate-300 text-slate-900 rounded-lg text-sm;

      input {
        @apply border-slate-300 text-sm;
      }
    }

    .multiselect__option {
      @apply flex items-center;
    }

    .mx-datepicker {
      .mx-input {
        background-color: transparent !important;
      }

      .mx-input-wrapper input::placeholder {
        @apply text-slate-900;
      }

      .mx-input-wrapper input {
        @apply text-slate-900;
      }
    }

    .multiselect--active:not(.multiselect--above) .multiselect__current,
    .multiselect--active:not(.multiselect--above) .multiselect__input,
    .multiselect--active:not(.multiselect--above) .multiselect__tags {
      @apply rounded-b-none;
    }
  }
}
</style>
