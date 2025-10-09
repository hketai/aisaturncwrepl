<script setup>
import Spinner from 'shared/components/Spinner.vue';

defineProps({
  header: {
    type: String,
    default: '',
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
  loadingMessage: {
    type: String,
    default: '',
  },
});
</script>

<template>
  <div
    class="flex flex-col m-0.5 px-6 py-5 rounded-xl flex-grow text-slate-900 shadow outline-1 outline outline-slate-300 bg-slate-200 min-h-[10rem]"
  >
    <div
      class="card-header grid w-full mb-6 grid-cols-[repeat(auto-fit,minmax(max-content,50%))] gap-y-2"
    >
      <slot name="header">
        <div class="flex items-center gap-2 flex-row">
          <h5 class="mb-0 text-slate-900 font-medium text-lg">
            {{ header }}
          </h5>
          <span
            class="flex flex-row items-center py-0.5 px-2 rounded bg-teal-200 text-xs"
          >
            <span
              class="bg-teal-800 h-1 w-1 rounded-full mr-1 rtl:mr-0 rtl:ml-0"
            />
            <span class="text-xs text-teal-900">
              {{ $t('OVERVIEW_REPORTS.LIVE') }}
            </span>
          </span>
        </div>
        <div class="flex flex-row items-center justify-end gap-2">
          <slot name="control" />
        </div>
      </slot>
    </div>
    <div
      v-if="!isLoading"
      class="card-body max-w-full w-full ml-auto mr-auto justify-between flex"
    >
      <slot />
    </div>
    <div
      v-else-if="isLoading"
      class="items-center flex text-base justify-center px-12 py-6"
    >
      <Spinner />
      <span class="text-slate-900">
        {{ loadingMessage }}
      </span>
    </div>
  </div>
</template>
