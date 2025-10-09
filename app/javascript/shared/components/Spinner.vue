<script>
export default {
  props: {
    size: {
      type: String,
      default: 'small',
    },
    colorScheme: {
      type: String,
      default: '',
    },
  },
  computed: {
    colorSchemeClasses() {
      if (this.colorScheme === 'primary') {
        return 'before:!border-t-indigo-600';
      }

      if (this.colorScheme === 'warning') {
        return 'before:!border-t-amber-500';
      }

      if (this.colorScheme === 'success') {
        return 'before:!border-t-teal-800';
      }

      return this.colorScheme;
    },
  },
};
</script>

<template>
  <span class="spinner" :class="`${size} ${colorSchemeClasses}`" />
</template>

<style scoped lang="scss">
@keyframes spinner {
  to {
    transform: rotate(360deg);
  }
}

.spinner {
  @apply relative inline-block w-6 h-6 align-middle;

  &:before {
    @apply border-slate-900 border-2 border-solid content-[''] box-border absolute top-[50%] left-[50%] rounded-full border-t-slate-400 -ml-2.5 -mt-2.5 w-6 h-6 animate-[spinner_0.9s_linear_infinite];
  }

  &.message {
    @apply p-2.5 top-0 left-0 mx-auto my-0 mt-3 bg-white rounded-[2rem];

    &:before {
      @apply -mt-3 -ml-3;
    }
  }

  &.small {
    @apply w-4 h-4;

    &:before {
      @apply w-4 h-4 -mt-2;
    }
  }

  &.tiny {
    @apply w-2.5 h-2.5 py-0 px-1;

    &:before {
      @apply w-2.5 h-2.5 -mt-1.5;
    }
  }
}
</style>
