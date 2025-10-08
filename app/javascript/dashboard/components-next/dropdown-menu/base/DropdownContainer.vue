<script setup>
import { useToggle } from '@vueuse/core';
import { vOnClickOutside } from '@vueuse/components';
import { provideDropdownContext } from './provider.js';

const emit = defineEmits(['close']);
const [isOpen, toggle] = useToggle(false);

const toggleWithLog = () => {
  console.log('Dropdown toggle clicked, current state:', isOpen.value);
  toggle();
  console.log('Dropdown new state:', isOpen.value);
};

const closeMenu = () => {
  if (isOpen.value) {
    console.log('Closing dropdown menu');
    emit('close');
    toggle(false);
  }
};

provideDropdownContext({
  isOpen,
  toggle: toggleWithLog,
  closeMenu,
});
</script>

<template>
  <div v-on-click-outside="closeMenu" class="relative space-y-2">
    <slot name="trigger" :is-open :toggle="toggleWithLog" />
    <div v-if="isOpen" class="absolute" style="background: red; padding: 20px;">
      DEBUG: Dropdown is open!
      <slot />
    </div>
  </div>
</template>
