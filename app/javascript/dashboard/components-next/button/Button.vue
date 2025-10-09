<script setup>
import { computed, useSlots, useAttrs } from 'vue';

import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import {
  VARIANT_OPTIONS,
  COLOR_OPTIONS,
  JUSTIFY_OPTIONS,
  SIZE_OPTIONS,
  EXCLUDED_ATTRS,
} from './constants.js';

const props = defineProps({
  label: { type: [String, Number], default: '' },
  variant: {
    type: String,
    default: null,
    validator: value => VARIANT_OPTIONS.includes(value) || value === null,
  },
  color: {
    type: String,
    default: null,
    validator: value => COLOR_OPTIONS.includes(value) || value === null,
  },
  size: {
    type: String,
    default: null,
    validator: value => SIZE_OPTIONS.includes(value) || value === null,
  },
  justify: {
    type: String,
    default: null,
    validator: value => JUSTIFY_OPTIONS.includes(value) || value === null,
  },
  icon: { type: [String, Object, Function], default: '' },
  trailingIcon: { type: Boolean, default: false },
  isLoading: { type: Boolean, default: false },
});

const slots = useSlots();
const attrs = useAttrs();

defineOptions({
  inheritAttrs: false,
});

const filteredAttrs = computed(() => {
  const standardAttrs = {};

  Object.entries(attrs)
    .filter(([key]) => !EXCLUDED_ATTRS.includes(key))
    .forEach(([key, value]) => {
      standardAttrs[key] = value;
    });

  return standardAttrs;
});

const computedVariant = computed(() => {
  if (props.variant) return props.variant;
  // The useAttrs method returns attributes values an empty string (not boolean value as in props).
  if (attrs.solid || attrs.solid === '') return 'solid';
  if (attrs.outline || attrs.outline === '') return 'outline';
  if (attrs.faded || attrs.faded === '') return 'faded';
  if (attrs.link || attrs.link === '') return 'link';
  if (attrs.ghost || attrs.ghost === '') return 'ghost';
  return 'solid'; // Default variant
});

const computedColor = computed(() => {
  if (props.color) return props.color;
  if (attrs.blue || attrs.blue === '') return 'blue';
  if (attrs.ruby || attrs.ruby === '') return 'ruby';
  if (attrs.amber || attrs.amber === '') return 'amber';
  if (attrs.slate || attrs.slate === '') return 'slate';
  if (attrs.teal || attrs.teal === '') return 'teal';
  return 'blue'; // Default color
});

const computedSize = computed(() => {
  if (props.size) return props.size;
  if (attrs.xs || attrs.xs === '') return 'xs';
  if (attrs.sm || attrs.sm === '') return 'sm';
  if (attrs.md || attrs.md === '') return 'md';
  if (attrs.lg || attrs.lg === '') return 'lg';
  return 'md';
});

const computedJustify = computed(() => {
  if (props.justify) return props.justify;
  if (attrs.start || attrs.start === '') return 'start';
  if (attrs.center || attrs.center === '') return 'center';
  if (attrs.end || attrs.end === '') return 'end';

  return 'center';
});

const STYLE_CONFIG = {
  colors: {
    blue: {
      solid:
        'bg-indigo-600 text-white hover:enabled:shadow-md hover:enabled:-translate-y-0.5 focus-visible:shadow-md focus-visible:-translate-y-0.5 outline-transparent active:translate-y-0',
      faded:
        'bg-indigo-600/10 text-indigo-700 hover:enabled:bg-indigo-600/20 hover:enabled:shadow focus-visible:bg-indigo-600/20 outline-transparent',
      outline: 'text-indigo-700 outline-indigo-600 hover:enabled:bg-indigo-600/5',
      ghost:
        'text-indigo-700 hover:enabled:bg-slate-900/10 focus-visible:bg-slate-900/10 outline-transparent',
      link: 'text-indigo-700 hover:enabled:underline focus-visible:underline outline-transparent',
    },
    ruby: {
      solid:
        'bg-red-800 text-white hover:enabled:shadow-md hover:enabled:-translate-y-0.5 focus-visible:shadow-md focus-visible:-translate-y-0.5 outline-transparent active:translate-y-0',
      faded:
        'bg-red-800/10 text-red-900 hover:enabled:bg-red-800/20 hover:enabled:shadow focus-visible:bg-red-800/20 outline-transparent',
      outline:
        'text-red-900 hover:enabled:bg-red-800/10 focus-visible:bg-red-800/10 outline-red-700',
      ghost:
        'text-red-900 hover:enabled:bg-slate-900/10 focus-visible:bg-slate-900/10 outline-transparent',
      link: 'text-red-800 dark:text-red-900 hover:enabled:underline focus-visible:underline outline-transparent',
    },
    amber: {
      solid:
        'bg-amber-800 text-white hover:enabled:shadow-md hover:enabled:-translate-y-0.5 focus-visible:shadow-md focus-visible:-translate-y-0.5 outline-transparent active:translate-y-0',
      faded:
        'bg-amber-800/10 text-slate-900 hover:enabled:bg-amber-800/20 hover:enabled:shadow focus-visible:bg-amber-800/20 outline-transparent',
      outline:
        'text-amber-900 hover:enabled:bg-amber-800/10 focus-visible:bg-amber-800/10 outline-amber-800',
      link: 'text-amber-800 hover:enabled:underline focus-visible:underline outline-transparent',
      ghost:
        'text-amber-800 hover:enabled:bg-slate-900/10 focus-visible:bg-slate-900/10 outline-transparent',
    },
    slate: {
      solid:
        'bg-slate-300 dark:hover:enabled:bg-slate-200 dark:focus-visible:bg-slate-200 hover:enabled:bg-slate-900/10 hover:enabled:shadow-md hover:enabled:-translate-y-0.5 focus-visible:bg-slate-900/10 focus-visible:shadow-md focus-visible:-translate-y-0.5 text-slate-900 outline-slate-300 active:translate-y-0',
      faded:
        'bg-slate-800/10 text-slate-900 hover:enabled:bg-slate-800/20 hover:enabled:shadow focus-visible:bg-slate-800/20 outline-transparent',
      outline:
        'text-slate-900 outline-slate-400 hover:enabled:bg-slate-800/10 focus-visible:bg-slate-800/10',
      link: 'text-slate-900 hover:enabled:text-slate-900 focus-visible:text-slate-900 hover:enabled:underline focus-visible:underline outline-transparent',
      ghost:
        'text-slate-900 hover:enabled:bg-slate-900/10 focus-visible:bg-slate-900/10 outline-transparent',
    },
    teal: {
      solid:
        'bg-teal-800 text-white hover:enabled:shadow-md hover:enabled:-translate-y-0.5 focus-visible:shadow-md focus-visible:-translate-y-0.5 outline-transparent active:translate-y-0',
      faded:
        'bg-teal-800/10 text-slate-900 hover:enabled:bg-teal-800/20 hover:enabled:shadow focus-visible:bg-teal-800/20 outline-transparent',
      outline:
        'text-teal-900 hover:enabled:bg-teal-800/10 focus-visible:bg-teal-800/10 outline-teal-800',
      link: 'text-teal-800 hover:enabled:underline focus-visible:underline outline-transparent',
      ghost:
        'text-teal-800 hover:enabled:bg-slate-900/10 focus-visible:bg-slate-900/10 outline-transparent',
    },
  },
  sizes: {
    regular: {
      xs: 'h-6 px-2',
      sm: 'h-8 px-3',
      md: 'h-10 px-4',
      lg: 'h-12 px-5',
    },
    iconOnly: {
      xs: 'h-6 w-6 p-0',
      sm: 'h-8 w-8 p-0',
      md: 'h-10 w-10 p-0',
      lg: 'h-12 w-12 p-0',
    },
    link: {
      xs: 'p-0',
      sm: 'p-0',
      md: 'p-0',
      lg: 'p-0',
    },
  },
  fontSize: {
    xs: 'text-xs',
    sm: 'text-sm',
    md: 'text-sm font-medium',
    lg: 'text-base',
  },
  justify: {
    start: 'justify-start',
    center: 'justify-center',
    end: 'justify-end',
  },
  base: 'inline-flex items-center min-w-0 gap-2 transition-all duration-200 ease-in-out border-0 rounded-md outline-1 outline disabled:opacity-50 font-medium shadow-sm',
};

const variantClasses = computed(() => {
  const variantMap = {
    ghost: `${STYLE_CONFIG.colors[computedColor.value].ghost}`,
    link: `${STYLE_CONFIG.colors[computedColor.value].link} p-0 font-medium underline-offset-2`,
    outline: STYLE_CONFIG.colors[computedColor.value].outline,
    faded: STYLE_CONFIG.colors[computedColor.value].faded,
    solid: STYLE_CONFIG.colors[computedColor.value].solid,
  };

  return variantMap[computedVariant.value];
});

const isIconOnly = computed(() => !props.label && !slots.default);
const isLink = computed(() => computedVariant.value === 'link');

const buttonClasses = computed(() => {
  const sizeConfig = isIconOnly.value ? 'iconOnly' : 'regular';
  const classes = [
    variantClasses.value,
    computedVariant.value !== 'link' &&
      STYLE_CONFIG.sizes[sizeConfig][computedSize.value],
  ].filter(Boolean);

  return classes.join(' ');
});

const linkButtonClasses = computed(() => {
  const classes = [
    variantClasses.value,
    STYLE_CONFIG.sizes.link[computedSize.value],
  ].filter(Boolean);

  return classes.join(' ');
});
</script>

<template>
  <button
    v-bind="filteredAttrs"
    :class="{
      [STYLE_CONFIG.base]: true,
      [isLink ? linkButtonClasses : buttonClasses]: true,
      [STYLE_CONFIG.fontSize[computedSize]]: true,
      [STYLE_CONFIG.justify[computedJustify]]: true,
      'flex-row-reverse': trailingIcon && !isIconOnly,
    }"
  >
    <slot v-if="(icon || $slots.icon) && !isLoading" name="icon">
      <Icon :icon="icon" class="flex-shrink-0" />
    </slot>

    <Spinner v-if="isLoading" class="!w-5 !h-5 flex-shrink-0" />

    <slot v-if="label || $slots.default" name="default">
      <span v-if="label" class="min-w-0 truncate">{{ label }}</span>
    </slot>
  </button>
</template>
