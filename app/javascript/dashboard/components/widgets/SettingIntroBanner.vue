<script>
export default {
  props: {
    headerTitle: {
      type: String,
      default: '',
    },
    headerContent: {
      type: String,
      default: '',
    },
  },
};
</script>

<template>
  <div class="border-b border-solid border-slate-300/60">
    <div class="max-w-6xl w-full mx-auto pt-4 pb-0 px-8">
      <h2 class="text-2xl text-slate-900 mb-1 font-medium">
        {{ headerTitle }}
      </h2>
      <p v-if="headerContent" class="w-full text-slate-900 text-sm mb-2">
        {{ headerContent }}
      </p>
      <slot />
    </div>
  </div>
</template>
