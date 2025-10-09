<script setup>
import Icon from 'next/icon/Icon.vue';

defineProps({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    default: '',
  },
  icon: {
    type: String,
    required: true,
  },
  isComingSoon: {
    type: Boolean,
    default: false,
  },
});
</script>

<template>
  <button
    class="relative bg-slate-100 gap-6 cursor-pointer rounded-2xl flex flex-col justify-start transition-all duration-200 ease-in -m-px py-6 px-5 items-start border border-solid border-slate-300"
    :class="{
      'hover:enabled:border-indigo-800 hover:enabled:shadow-md disabled:opacity-60 disabled:cursor-not-allowed':
        !isComingSoon,
      'cursor-not-allowed disabled:opacity-80': isComingSoon,
    }"
  >
    <div
      class="flex size-10 items-center justify-center rounded-full bg-slate-900/10"
    >
      <Icon :icon="icon" class="text-slate-900 size-6" />
    </div>

    <div class="flex flex-col items-start gap-1.5">
      <h3 class="text-slate-900 text-sm text-start font-medium capitalize">
        {{ title }}
      </h3>
      <p class="text-slate-900 text-start text-sm">
        {{ description }}
      </p>
    </div>

    <div
      v-if="isComingSoon"
      class="absolute inset-0 flex items-center justify-center backdrop-blur-[2px] rounded-2xl bg-gradient-to-br from-white/90 via-white/70 to-white/95 cursor-not-allowed"
    >
      <span class="text-slate-900 font-medium text-sm">
        {{ $t('CHANNEL_SELECTOR.COMING_SOON') }} 🚀
      </span>
    </div>
  </button>
</template>
