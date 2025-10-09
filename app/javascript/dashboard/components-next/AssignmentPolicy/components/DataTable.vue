<script setup>
import Avatar from 'next/avatar/Avatar.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

defineProps({
  items: {
    type: Array,
    default: () => [],
  },
  isFetching: {
    type: Boolean,
    default: false,
  },
  emptyStateMessage: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['delete']);

const handleDelete = itemId => {
  emit('delete', itemId);
};
</script>

<template>
  <div
    v-if="isFetching"
    class="flex items-center justify-center py-3 w-full text-slate-900"
  >
    <Spinner />
  </div>
  <div
    v-else-if="items.length === 0 && emptyStateMessage"
    class="custom-dashed-border flex items-center justify-center py-6 w-full"
  >
    <span class="text-sm text-slate-900">
      {{ emptyStateMessage }}
    </span>
  </div>
  <div v-else class="flex flex-col divide-y divide-slate-300">
    <div
      v-for="item in items"
      :key="item.id"
      class="grid grid-cols-4 items-center gap-3 min-w-0 w-full justify-between h-[3.25rem] ltr:pr-2 rtl:pl-2"
    >
      <div class="flex items-center gap-2 col-span-2">
        <Icon
          v-if="item.icon"
          :icon="item.icon"
          class="size-4 text-slate-900 flex-shrink-0"
        />
        <Avatar
          v-else
          :title="item.name"
          :src="item.avatarUrl"
          :name="item.name"
          :size="20"
          rounded-full
        />
        <span class="text-sm text-slate-900 truncate min-w-0">
          {{ item.name }}
        </span>
      </div>

      <div class="flex items-start gap-2 col-span-1">
        <span
          :title="item.email || item.phoneNumber"
          class="text-sm text-slate-900 truncate min-w-0"
        >
          {{ item.email || item.phoneNumber }}
        </span>
      </div>

      <div class="col-span-1 justify-end flex items-center">
        <Button
          icon="i-lucide-trash"
          slate
          ghost
          sm
          type="button"
          @click="handleDelete(item.id)"
        />
      </div>
    </div>
  </div>
</template>
