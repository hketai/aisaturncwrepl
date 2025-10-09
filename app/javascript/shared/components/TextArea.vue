<script>
export default {
  props: {
    label: {
      type: String,
      default: '',
    },
    placeholder: {
      type: String,
      default: '',
    },
    modelValue: {
      type: [String, Number],
      required: true,
    },
    error: {
      type: String,
      default: '',
    },
  },
  emits: ['update:modelValue'],
  computed: {
    computedModel: {
      get() {
        return this.modelValue;
      },
      set(value) {
        this.$emit('update:modelValue', value);
      },
    },
  },
};
</script>

<template>
  <label class="block">
    <div
      v-if="label"
      class="mb-2 text-xs font-medium"
      :class="{
        'text-gray-900': !error,
        'text-red-800': error,
      }"
    >
      {{ label }}
    </div>
    <textarea
      v-model="computedModel"
      class="w-full px-3 py-2 leading-tight border rounded outline-none resize-none text-gray-900"
      :class="{
        'border-slate-300 hover:border-slate-300 focus:border-slate-300': !error,
        'border-red-800 hover:border-red-800 focus:border-red-800': error,
      }"
      :placeholder="placeholder"
    />
    <div v-if="error" class="mt-2 text-xs font-medium text-red-800">
      {{ error }}
    </div>
  </label>
</template>

<style lang="scss" scoped>
textarea {
  min-height: 8rem;
}
</style>
