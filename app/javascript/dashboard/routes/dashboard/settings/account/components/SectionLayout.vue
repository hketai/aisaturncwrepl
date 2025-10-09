<script setup>
defineProps({
  title: { type: String, required: true },
  description: { type: String, required: true },
  withBorder: { type: Boolean, default: false },
  hideContent: { type: Boolean, default: false },
});
</script>

<template>
  <section
    class="grid grid-cols-1 pt-8 gap-5 [interpolate-size:allow-keywords]"
    :class="{
      'border-t border-slate-300': withBorder,
      'pb-8': !hideContent,
    }"
  >
    <header class="grid grid-cols-4">
      <div class="col-span-3">
        <h4 class="text-lg font-medium text-slate-900">
          <slot name="title">{{ title }}</slot>
        </h4>
        <p class="text-slate-900 text-sm mt-2">
          <slot name="description">{{ description }}</slot>
        </p>
      </div>
      <div class="col-span-1">
        <slot name="headerActions" />
      </div>
    </header>
    <div
      class="transition-[height] duration-300 ease-in-out text-slate-900"
      :class="{ 'overflow-hidden h-0': hideContent, 'h-auto': !hideContent }"
    >
      <slot />
    </div>
  </section>
</template>
