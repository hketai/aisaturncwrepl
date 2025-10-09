<script>
import CardButton from 'shared/components/CardButton.vue';

export default {
  components: {
    CardButton,
  },
  props: {
    title: {
      type: String,
      default: '',
    },
    description: {
      type: String,
      default: '',
    },
    mediaUrl: {
      type: String,
      default: '',
    },
    actions: {
      type: Array,
      default: () => [],
    },
  },
};
</script>

<template>
  <div
    class="card-message chat-bubble agent bg-white dark:bg-slate-300 max-w-56 rounded-lg overflow-hidden"
  >
    <img
      class="w-full object-contain max-h-[150px] rounded-[5px]"
      :src="mediaUrl"
    />
    <div class="card-body">
      <h4
        class="!text-base !font-medium !mt-1 !mb-1 !leading-[1.5] text-slate-900"
      >
        {{ title }}
      </h4>
      <p class="!mb-1 text-slate-900">
        {{ description }}
      </p>
      <CardButton v-for="action in actions" :key="action.id" :action="action" />
    </div>
  </div>
</template>
