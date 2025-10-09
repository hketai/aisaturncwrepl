<script>
import { getContrastingTextColor } from '@chatwoot/utils';

export default {
  props: {
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      default: '',
    },
    href: {
      type: String,
      default: '',
    },
    bgColor: {
      type: String,
      default: '',
    },
    small: {
      type: Boolean,
      default: false,
    },
    showClose: {
      type: Boolean,
      default: false,
    },
    icon: {
      type: String,
      default: '',
    },
    color: {
      type: String,
      default: '',
    },
    colorScheme: {
      type: String,
      default: '',
    },
    variant: {
      type: String,
      default: '',
    },
  },
  emits: ['remove'],
  computed: {
    textColor() {
      if (this.variant === 'smooth') return '';
      if (this.variant === 'dashed') return '';
      return this.color || getContrastingTextColor(this.bgColor);
    },
    labelClass() {
      return `label ${this.colorScheme} ${this.variant} ${
        this.small ? 'small' : ''
      }`;
    },
    labelStyle() {
      if (this.bgColor) {
        return {
          background: this.bgColor,
          color: this.textColor,
          border: `1px solid ${this.bgColor}`,
        };
      }
      return {};
    },
    anchorStyle() {
      if (this.bgColor) {
        return { color: this.textColor };
      }
      return {};
    },
  },
  methods: {
    onClick() {
      this.$emit('remove', this.title);
    },
  },
};
</script>

<template>
  <div
    class="inline-flex ltr:mr-1 rtl:ml-1 mb-1"
    :class="labelClass"
    :style="labelStyle"
    :title="description"
  >
    <span v-if="icon" class="label-action--button">
      <fluent-icon :icon="icon" size="12" class="label--icon cursor-pointer" />
    </span>
    <span
      v-if="['smooth', 'dashed'].includes(variant) && title && !icon"
      :style="{ background: color }"
      class="label-color-dot flex-shrink-0"
    />
    <span v-if="!href" class="whitespace-nowrap text-ellipsis overflow-hidden">
      {{ title }}
    </span>
    <a v-else :href="href" :style="anchorStyle">{{ title }}</a>
    <button
      v-if="showClose"
      class="label-close--button p-0"
      :style="{ color: textColor }"
      @click="onClick"
    >
      <fluent-icon icon="dismiss" size="12" class="close--icon" />
    </button>
  </div>
</template>

<style scoped lang="scss">
.label {
  @apply items-center font-medium text-xs rounded-[4px] gap-1 p-1 bg-slate-200 text-slate-900 border border-solid border-slate-400 h-6;

  &.small {
    @apply text-xs py-0.5 px-1 leading-tight h-5;
  }

  &.small .label--icon,
  &.small .close--icon {
    @apply text-[0.5rem];
  }

  a {
    @apply text-xs;
    &:hover {
      @apply underline;
    }
  }

  /* Color Schemes */
  &.primary {
    @apply bg-indigo-400 text-indigo-900 border border-solid border-indigo-600;

    a {
      @apply text-indigo-900;
    }
    .label-color-dot {
      @apply bg-indigo-800;
    }
  }
  &.secondary {
    @apply bg-slate-400 text-slate-900 border border-solid border-slate-600;

    a {
      @apply text-slate-900;
    }
    .label-color-dot {
      @apply bg-slate-800;
    }
  }
  &.success {
    @apply bg-teal-400 text-teal-900 border border-solid border-teal-600;

    a {
      @apply text-teal-900;
    }
    .label-color-dot {
      @apply bg-teal-800;
    }
  }
  &.alert {
    @apply bg-red-400 text-red-900 border border-solid border-red-600;

    a {
      @apply text-red-900;
    }
    .label-color-dot {
      @apply bg-red-800;
    }
  }
  &.warning {
    @apply bg-amber-400 text-amber-900 border border-solid border-amber-600;

    a {
      @apply text-amber-900;
    }
    .label-color-dot {
      @apply bg-amber-800;
    }
  }

  &.smooth {
    @apply bg-transparent text-slate-900 dark:text-slate-900 border border-solid border-slate-400;
  }

  &.dashed {
    @apply bg-transparent text-slate-900 dark:text-slate-900 border border-dashed border-slate-400;
  }
}

.label-close--button {
  @apply text-slate-900 -mb-0.5 rounded-sm cursor-pointer flex items-center justify-center hover:bg-slate-200;

  svg {
    @apply text-slate-900;
  }
}

.label-action--button {
  @apply flex mr-1;
}

.label-color-dot {
  @apply inline-block w-3 h-3 rounded-sm shadow-sm;
}
.label.small .label-color-dot {
  @apply w-2 h-2 rounded-sm shadow-sm;
}
</style>
