<script setup>
const props = defineProps({
  id: {
    type: String,
    required: true,
  },
  label: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  isActive: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['select']);

const handleChange = () => {
  if (!props.isActive) {
    emit('select', props.id);
  }
};
</script>

<template>
  <div
    class="relative cursor-pointer rounded-xl outline outline-1 p-4 transition-all duration-200 bg-slate-100 py-4 ltr:pl-4 rtl:pr-4 ltr:pr-6 rtl:pl-6"
    :class="[
      isActive ? 'outline-indigo-800' : 'outline-slate-300 hover:outline-slate-400',
    ]"
    @click="handleChange"
  >
    <div class="absolute top-4 right-4">
      <input
        :id="`${id}`"
        :checked="isActive"
        :value="id"
        :name="id"
        type="radio"
        class="h-4 w-4 border-slate-500 text-indigo-600 focus:ring-indigo-600 focus:ring-offset-0"
        @change="handleChange"
      />
    </div>

    <!-- Content -->
    <div class="flex flex-col gap-3 items-start">
      <h3 class="text-sm font-medium text-slate-900">
        {{ label }}
      </h3>
      <p class="text-sm text-slate-900">
        {{ description }}
      </p>
    </div>
  </div>
</template>
