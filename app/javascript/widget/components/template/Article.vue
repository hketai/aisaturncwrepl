<script>
import { useMessageFormatter } from 'shared/composables/useMessageFormatter';
import FluentIcon from 'shared/components/FluentIcon/Index.vue';

export default {
  components: {
    FluentIcon,
  },
  props: {
    items: {
      type: Array,
      default: () => [],
    },
  },
  setup() {
    const { truncateMessage } = useMessageFormatter();
    return { truncateMessage };
  },
};
</script>

<!-- eslint-disable-next-line vue/no-root-v-if -->
<template>
  <div
    v-if="!!items.length"
    class="chat-bubble agent bg-white dark:bg-slate-300"
  >
    <div
      v-for="item in items"
      :key="item.link"
      class="border-b border-solid border-slate-300 text-sm py-2 px-0 last:border-b-0"
    >
      <a
        :href="item.link"
        target="_blank"
        rel="noopener noreferrer nofollow"
        class="text-slate-900 no-underline"
      >
        <span class="flex items-center text-slate-900 font-medium">
          <FluentIcon icon="link" class="ltr:mr-1 rtl:ml-1 text-slate-900" />
          <span class="text-slate-900">
            {{ item.title }}
          </span>
        </span>
        <span class="block mt-1 text-slate-900">
          {{ truncateMessage(item.description) }}
        </span>
      </a>
    </div>
  </div>
</template>
