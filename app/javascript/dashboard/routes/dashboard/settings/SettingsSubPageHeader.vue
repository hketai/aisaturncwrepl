<script>
export default {
  props: {
    headerTitle: { type: String, default: '' },
    headerContent: { type: String, default: '' },
  },
};
</script>

<template>
  <div class="flex flex-col w-full items-start mb-4">
    <h2 class="text-xl font-medium mb-1 text-slate-900 break-words">
      {{ headerTitle }}
    </h2>
    <p
      v-dompurify-html="headerContent"
      class="text-sm w-full text-slate-900"
    />
  </div>
</template>
